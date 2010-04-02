package MTMLTwitterAPI;
use strict;
use warnings;
use MT;
use HTTP::Request::Common;

sub _hdlr_mentions {
    my ( $ctx, $args, $cond ) = @_;
    require JSON;
    my $endpoint = $args->{endpoint} || "http://twitter.com/";
    $endpoint .= "statuses/mentions.json";
    my $username = $args->{username}
        or return $ctx->error(MT->translate('[_1] needs username attribute.', $ctx->stash('tag')));
    my $password = $args->{password}
        or return $ctx->error(MT->translate('[_1] needs password attribute.', $ctx->stash('tag')));
    my $ua_args = {
        timeout => $args->{timeout} || 10,
    };
    my $ua = MT->new_ua( $ua_args );
    my $req = GET( $endpoint );
    $req->authorization_basic($username, $password);

    my $res = $ua->request($req);
    my $return = JSON::from_json($res->content);
    my $error;
    if ( 'HASH' eq ref $return ) {
        $error = $return->{error};
    }
    if ( $error ) {
        if ( $args->{fatal_error} ) {
            return $ctx->error( MT->translate( 'Failed to update twitter: [_1]', $error ) );
        }
        else {
            MT->log( MT->translate( 'Failed to update twitter: [_1]', $error ) );
            return '';
        }
    }
    my @mentions = reverse @$return;
    my $last = 0;
    my $pd;
    my $new_mentions_only = exists $args->{new_mentions_only} ? $args->{new_mentions_only} : 1;
    if ( $new_mentions_only ) {
        my $api_id = sprintf "%s:%s:%s", 'Mentions', ( $args->{namespace} || 'MTMLTwitterAPI' ), $username;
        my $plugin = 'MTMLTwitterAPI';
        $pd = MT->model('plugindata')->load({ key => $api_id });
        if ( $pd ) {
            my $data = $pd->data;
            $last = $data->{last};
        }
        else {
            $pd = MT->model('plugindata')->new;
            $pd->plugin('MTMLTwitterAPI');
            $pd->key($api_id);
        }
    }
    my $out;
    for my $mention ( @mentions ) {
        my $id = $mention->{id};
        next if ( $last > 0 && $last >= $id );
        $last = $id;
        $ctx->var( 'id', $id );
        $ctx->var( 'text', $mention->{text} );
        $ctx->var( 'name', $mention->{user}{name} );
        $ctx->var( 'screen_name', $mention->{user}{screen_name} );
        my $res = $ctx->slurp( $args, $cond );
        $out .= $res;
    }
    if ( $new_mentions_only ) {
        $pd->data({last => $last });
        $pd->save;
    }
    return $out;
}

sub _hdlr_friends_timeline {
    my ( $ctx, $args, $cond ) = @_;
    require JSON;
    my $endpoint = $args->{endpoint} || "http://twitter.com/";
    $endpoint .= "statuses/friends_timeline.json";
    my $username = $args->{username}
        or return $ctx->error(MT->translate('[_1] needs username attribute.', $ctx->stash('tag')));
    my $password = $args->{password}
        or return $ctx->error(MT->translate('[_1] needs password attribute.', $ctx->stash('tag')));
    my $ua_args = {
        timeout => $args->{timeout} || 10,
    };
    my $ua = MT->new_ua( $ua_args );
    my $req = GET( $endpoint );
    $req->authorization_basic($username, $password);

    my $res = $ua->request($req);
    my $return = JSON::from_json($res->content);
    my $error;
    if ( 'HASH' eq ref $return ) {
        $error = $return->{error};
    }
    if ( $error ) {
        if ( $args->{fatal_error} ) {
            return $ctx->error( MT->translate( 'Failed to update twitter: [_1]', $error ) );
        }
        else {
            MT->log( MT->translate( 'Failed to update twitter: [_1]', $error ) );
            return '';
        }
    }
    my @mentions = reverse @$return;
    my $last = 0;
    my $pd;
    my $new_mentions_only = exists $args->{new_mentions_only} ? $args->{new_mentions_only} : 1;
    if ( $new_mentions_only ) {
        my $api_id = sprintf "%s:%s:%s", 'Mentions', ( $args->{namespace} || 'MTMLTwitterAPI' ), $username;
        my $plugin = 'MTMLTwitterAPI';
        $pd = MT->model('plugindata')->load({ key => $api_id });
        if ( $pd ) {
            my $data = $pd->data;
            $last = $data->{last};
        }
        else {
            $pd = MT->model('plugindata')->new;
            $pd->plugin('MTMLTwitterAPI');
            $pd->key($api_id);
        }
    }
    my $out;
    for my $mention ( @mentions ) {
        my $id = $mention->{id};
        next if ( $last > 0 && $last >= $id );
        $last = $id;
        $ctx->var( 'id', $id );
        $ctx->var( 'text', $mention->{text} );
        $ctx->var( 'name', $mention->{user}{name} );
        $ctx->var( 'screen_name', $mention->{user}{screen_name} );
        my $res = $ctx->slurp( $args, $cond );
        $out .= $res;
    }
    if ( $new_mentions_only ) {
        $pd->data({last => $last });
        $pd->save;
    }
    return $out;
}

sub _hdlr_status_update {
    my ( $ctx, $args, $cond ) = @_;
    require JSON;
    my $endpoint = $args->{endpoint} || "http://twitter.com/";
    $endpoint .= "statuses/update.json";
    my $username = $args->{username}
        or return $ctx->error(MT->translate('[_1] needs username attribute.', $ctx->stash('tag')));
    my $password = $args->{password}
        or return $ctx->error(MT->translate('[_1] needs password attribute.', $ctx->stash('tag')));
    my $ua_args = {
        timeout => $args->{timeout} || 5,
    };
    my $ua = MT->new_ua( $ua_args );
    my $status = $ctx->slurp($args, $cond);
    my $req = POST( $endpoint, [ status => $status ] );
    $req->authorization_basic($username, $password);

    my $res = $ua->request($req);
    my $return = JSON::from_json($res->content);

    if ( my $error = $return->{error} ) {
        if ( $args->{fatal_error} ) {
            return $ctx->error( MT->translate( 'Failed to update twitter: [_1]', $error ) );
        }
        else {
            MT->log( MT->translate( 'Failed to update twitter: [_1]', $error ) );
        }
    }
    return '';
}

1;
