--魔弾の射手 マックス
-- 效果：
-- 8星以下的「魔弹」怪兽1只
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡连接召唤的场合，可以从以下效果选择1个发动。
-- ●把最多有对方场上的怪兽数量的「魔弹」魔法·陷阱卡从卡组加入手卡（同名卡最多1张）。
-- ●把最多有对方场上的魔法·陷阱卡数量的「魔弹」怪兽从卡组特殊召唤（同名卡最多1张）。
-- ②：只要这张卡在怪兽区域存在，自己·对方回合自己可以把「魔弹」魔法·陷阱卡从手卡发动。
function c71791814.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置连接召唤的手续，需要1只满足过滤条件的怪兽作为素材
	aux.AddLinkProcedure(c,c71791814.matfilter,1,1)
	-- ①：这张卡连接召唤的场合，可以从以下效果选择1个发动。●把最多有对方场上的怪兽数量的「魔弹」魔法·陷阱卡从卡组加入手卡（同名卡最多1张）。●把最多有对方场上的魔法·陷阱卡数量的「魔弹」怪兽从卡组特殊召唤（同名卡最多1张）。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,71791814)
	e1:SetCondition(c71791814.effcon)
	e1:SetTarget(c71791814.efftg)
	e1:SetOperation(c71791814.effop)
	c:RegisterEffect(e1)
	-- ②：只要这张卡在怪兽区域存在，自己·对方回合自己可以把「魔弹」魔法·陷阱卡从手卡发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(71791814,4))  --"适用「魔弹射手 马克斯」的效果来发动"
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_QP_ACT_IN_NTPHAND)
	e2:SetRange(LOCATION_MZONE)
	-- 设置手牌发动效果的对象为「魔弹」字段的卡片
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x108))
	e2:SetTargetRange(LOCATION_HAND,0)
	e2:SetValue(32841045)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	c:RegisterEffect(e3)
end
-- 连接素材过滤条件：8星以下的「魔弹」怪兽
function c71791814.matfilter(c)
	return c:IsLevelBelow(8) and c:IsLinkSetCard(0x108)
end
-- 效果①的发动条件：此卡是连接召唤成功的场合
function c71791814.effcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- 检索过滤条件：卡组中的「魔弹」魔法·陷阱卡且能加入手牌
function c71791814.thfilter(c)
	return c:IsSetCard(0x108) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 特殊召唤过滤条件：卡组中的「魔弹」怪兽且能特殊召唤
function c71791814.spfilter(c,e,tp)
	return c:IsSetCard(0x108) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的靶向/选择分支处理：检测两个分支是否满足发动条件，并由玩家选择其中一个效果发动
function c71791814.efftg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方场上是否存在怪兽（用于判断分支1是否可行）
	local b1=Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0
		-- 并且自己卡组中存在可以检索的「魔弹」魔法·陷阱卡
		and Duel.IsExistingMatchingCard(c71791814.thfilter,tp,LOCATION_DECK,0,1,nil)
	-- 检查自己场上是否有可用的怪兽区域空格（用于判断分支2是否可行）
	local b2=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且对方场上存在魔法·陷阱卡
		and Duel.GetMatchingGroupCount(Card.IsType,tp,0,LOCATION_ONFIELD,nil,TYPE_SPELL+TYPE_TRAP)>0
		-- 并且自己卡组中存在可以特殊召唤的「魔弹」怪兽
		and Duel.IsExistingMatchingCard(c71791814.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp)
	if chk==0 then return b1 or b2 end
	local op=0
	-- 如果两个分支都满足，则让玩家选择发动“检索魔陷”或“特殊召唤”效果
	if b1 and b2 then op=Duel.SelectOption(tp,aux.Stringid(71791814,0),aux.Stringid(71791814,1))  --"检索魔陷/特殊召唤"
	-- 如果只有分支1满足，则只能选择“检索魔陷”效果
	elseif b1 then op=Duel.SelectOption(tp,aux.Stringid(71791814,0))  --"检索魔陷"
	-- 否则（只有分支2满足），只能选择“特殊召唤”效果
	else op=Duel.SelectOption(tp,aux.Stringid(71791814,1))+1 end  --"特殊召唤"
	e:SetLabel(op)
	if op==0 then
		-- 向对方玩家提示自己选择了“检索魔陷”效果
		Duel.Hint(HINT_OPSELECTED,1-tp,aux.Stringid(71791814,0))  --"检索魔陷"
		e:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
		-- 设置连锁信息：此效果包含从卡组将卡加入手牌的操作
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	else
		-- 向对方玩家提示自己选择了“特殊召唤”效果
		Duel.Hint(HINT_OPSELECTED,1-tp,aux.Stringid(71791814,1))  --"特殊召唤"
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		-- 设置连锁信息：此效果包含从卡组特殊召唤怪兽的操作
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
	end
end
-- 效果①的执行函数：根据玩家的选择，执行检索「魔弹」魔陷或特殊召唤「魔弹」怪兽的操作
function c71791814.effop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==0 then
		-- 获取对方场上的怪兽数量（作为检索数量的上限）
		local ct=Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)
		-- 获取自己卡组中所有满足条件的「魔弹」魔法·陷阱卡
		local g=Duel.GetMatchingGroup(c71791814.thfilter,tp,LOCATION_DECK,0,nil)
		if ct<=0 or g:GetCount()==0 then return end
		-- 提示玩家选择要加入手牌的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 让玩家从卡组中选择最多等同于对方场上怪兽数量、且卡名各不相同的「魔弹」魔法·陷阱卡
		local sg=g:SelectSubGroup(tp,aux.dncheck,false,1,ct)
		-- 将选中的卡片通过效果加入手牌
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手牌的卡片
		Duel.ConfirmCards(1-tp,sg)
	else
		-- 获取自己场上可用的怪兽区域空格数
		local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
		-- 获取对方场上的魔法·陷阱卡数量（作为特殊召唤数量的上限）
		local ct=Duel.GetMatchingGroupCount(Card.IsType,tp,0,LOCATION_ONFIELD,nil,TYPE_SPELL+TYPE_TRAP)
		-- 获取自己卡组中所有满足条件的「魔弹」怪兽
		local g=Duel.GetMatchingGroup(c71791814.spfilter,tp,LOCATION_DECK,0,nil,e,tp)
		if ft<=0 or ct<=0 or g:GetCount()==0 then return end
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
		-- 提示玩家选择要特殊召唤的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让玩家从卡组中选择最多等同于对方场上魔陷数量（且不超过可用怪兽区域数）、卡名各不相同的「魔弹」怪兽
		local sg=g:SelectSubGroup(tp,aux.dncheck,false,1,math.min(ft,ct))
		-- 将选中的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
	end
end
