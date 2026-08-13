--無謀な欲張り
-- 效果：
-- ①：自己从卡组抽2张，那之后的自己抽卡阶段跳过2次。
function c37576645.initial_effect(c)
	-- 对应效果原文“①：自己从卡组抽2张，那之后的自己抽卡阶段跳过2次。”
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c37576645.target)
	e1:SetOperation(c37576645.activate)
	c:RegisterEffect(e1)
end
-- 发动时的目标与合法性判定：检查自己能否抽2张卡；若可以，将连锁的效果对象玩家设为自己、对象参数设为2，并登记一个抽卡效果的操作信息，供后续处理与连锁判定使用。
function c37576645.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动合法性检查阶段（chk==0）时，返回自己是否能够效果抽2张卡，作为该卡能否发动的条件。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	-- 将本连锁的效果对象玩家设置为当前发动者tp（即自己），表示抽卡动作的承受玩家为自己。
	Duel.SetTargetPlayer(tp)
	-- 将本连锁的效果对象参数设置为2，表示之后效果处理时需要抽2张卡。
	Duel.SetTargetParam(2)
	-- 登记操作信息：效果类别为抽卡（CATEGORY_DRAW），对象暂不指定（nil），目标玩家为自己（tp），预计抽取数量为2，使其他卡能正确响应/检测此抽卡效果。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
-- 效果处理：从连锁信息中取出目标玩家和抽卡数，让该玩家抽对应数量的卡；随后创建一个跳过该玩家抽卡阶段的永续效果并注册，使其跳过2次抽卡阶段。
function c37576645.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中取得此前登记的目标玩家p和参数d（即抽卡数量），供后续抽卡处理使用。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果原因让玩家p抽d张卡（此处即自己抽2张）。
	Duel.Draw(p,d,REASON_EFFECT)
	-- 对应效果原文中的“那之后的自己抽卡阶段跳过2次。”
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_SKIP_DP)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_END,5)
	-- 将由本卡生成的“跳过抽卡阶段”效果e1注册给玩家tp，使其从下次开始持续跳过tp的2次抽卡阶段。
	Duel.RegisterEffect(e1,tp)
end
