--マジェスペクター・オルト
-- 效果：
-- 包含「威风妖怪」怪兽的灵摆怪兽2只
-- 这个卡名的效果1回合只能使用1次。
-- ①：这张卡连接召唤的场合才能发动。从自己的额外卡组（表侧）把最多2只「威风妖怪」灵摆怪兽加入手卡。那之后，可以从卡组把最多2只「威风妖怪」灵摆怪兽表侧加入额外卡组（同名卡最多1张）。这个效果的发动后，直到回合结束时自己不是「威风妖怪」怪兽以及「龙剑士」怪兽不能从额外卡组特殊召唤。
local s,id,o=GetID()
-- 初始化卡片效果（添加连接召唤手续、苏生限制以及注册连接召唤成功的诱发效果）
function s.initial_effect(c)
	-- 设置以包含「威风妖怪」怪兽的灵摆怪兽2只为素材的连接召唤手续
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkType,TYPE_PENDULUM),2,2,s.lcheck)
	c:EnableReviveLimit()
	-- 这个卡名的效果1回合只能使用1次。①：这张卡连接召唤的场合才能发动。从自己的额外卡组（表侧）把最多2只「威风妖怪」灵摆怪兽加入手卡。那之后，可以从卡组把最多2只「威风妖怪」灵摆怪兽表侧加入额外卡组（同名卡最多1张）。这个效果的发动后，直到回合结束时自己不是「威风妖怪」怪兽以及「龙剑士」怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"额外卡组灵摆怪兽加入手卡"
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.thcon)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
end
-- 检查连接素材中是否包含至少1只「威风妖怪」怪兽
function s.lcheck(g,lc)
	return g:IsExists(Card.IsLinkSetCard,1,nil,0xd0)
end
-- 判定是否为自身连接召唤成功的场合
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- 过滤额外卡组表侧表示可加入手卡的「威风妖怪」灵摆怪兽
function s.thfilter(c)
	return c:IsSetCard(0xd0) and c:IsType(TYPE_PENDULUM) and c:IsFaceup() and c:IsAbleToHand()
end
-- 过滤卡组中的「威风妖怪」灵摆怪兽
function s.tefilter(c)
	return c:IsSetCard(0xd0) and c:IsType(TYPE_PENDULUM)
end
-- 检索加入手卡效果的目标确认与操作信息设置
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自身额外卡组表侧表示是否存在可以加入手卡的「威风妖怪」灵摆怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_EXTRA,0,1,nil) end
	-- 设置从额外卡组将卡加入手卡的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_EXTRA)
end
-- 执行从额外卡组回收灵摆怪兽并从卡组表侧加入额外卡组的效果处理
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 设置选择加入手卡卡片的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从额外卡组表侧表示选择最多2只「威风妖怪」灵摆怪兽
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_EXTRA,0,1,2,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家出示确认加入手卡的卡片
		Duel.ConfirmCards(1-tp,g)
		-- 洗切自身手卡
		Duel.ShuffleHand(tp)
		-- 获取卡组中所有的「威风妖怪」灵摆怪兽
		local cg=Duel.GetMatchingGroup(s.tefilter,tp,LOCATION_DECK,0,nil)
		-- 询问玩家是否从卡组把灵摆怪兽加入额外卡组
		if #cg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then  --"是否从卡组把灵摆怪兽加入额外卡组？"
			-- 设置选择加入额外卡组卡片的提示信息
			Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,2))  --"请选择要加入额外卡组的卡"
			-- 从卡组选择最多2只卡名不同的「威风妖怪」灵摆怪兽
			local hg=cg:SelectSubGroup(tp,aux.dncheck,false,1,2)
			if hg then
				-- 中断效果处理，使之后的加入额外卡组视为不同时处理
				Duel.BreakEffect()
				-- 将选中的灵摆怪兽表侧表示送去额外卡组
				Duel.SendtoExtraP(hg,nil,REASON_EFFECT)
			end
		end
	end
	-- 这个效果的发动后，直到回合结束时自己不是「威风妖怪」怪兽以及「龙剑士」怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册对自身生效的额外卡组特殊召唤限制效果
	Duel.RegisterEffect(e1,tp)
end
-- 限制不能从额外卡组特殊召唤「威风妖怪」与「龙剑士」以外的怪兽
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsSetCard(0xd0,0xc7) and c:IsLocation(LOCATION_EXTRA)
end
