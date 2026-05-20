--ブルーミー
-- 效果：
-- 这个卡名的效果1回合只能使用1次，把这张卡作为同调素材的场合，不是8星以下的怪兽的同调召唤不能使用。
-- ①：把手卡的这张卡和手卡1只怪兽给对方观看才能发动。那2只之内的1只特殊召唤，另1只除外。这个效果的发动后，直到回合结束时自己不是同调怪兽不能从额外卡组特殊召唤，不用同调怪兽不能攻击宣言。
local s,id,o=GetID()
-- 初始化函数，注册卡片效果：手牌发动的起动效果，以及作为同调素材时的限制效果
function s.initial_effect(c)
	-- ①：把手卡的这张卡和手卡1只怪兽给对方观看才能发动。那2只之内的1只特殊召唤，另1只除外。这个效果的发动后，直到回合结束时自己不是同调怪兽不能从额外卡组特殊召唤，不用同调怪兽不能攻击宣言。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.rmcost)
	e1:SetTarget(s.rmtg)
	e1:SetOperation(s.rmop)
	c:RegisterEffect(e1)
	-- 把这张卡作为同调素材的场合，不是8星以下的怪兽的同调召唤不能使用。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetValue(s.synlimit)
	c:RegisterEffect(e2)
end
-- 过滤手牌中可与此卡一同展示的怪兽（必须是怪兽卡、未公开，且两张卡中至少有一张能特召、另一张能除外）
function s.costfilter(c,ec,e,tp)
	if not c:IsType(TYPE_MONSTER) or c:IsPublic() then return false end
	local g=Group.FromCards(c,ec)
	return g:IsExists(s.tgspfilter,1,nil,g,e,tp)
end
-- 过滤两张卡中可以特殊召唤，且另一张卡可以被除外的卡
function s.tgspfilter(c,g,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false) and g:IsExists(Card.IsAbleToRemove,1,c)
end
-- 效果①的发动代价（Cost）处理函数，展示手牌的这张卡和另一只怪兽
function s.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查手牌中的这张卡是否未公开，且手牌中是否存在另一只满足条件的怪兽
	if chk==0 then return not c:IsPublic() and Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND,0,1,c,c,e,tp) end
	-- 提示玩家选择要给对方确认的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 玩家选择手牌中除这张卡以外的1只怪兽
	local sc=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_HAND,0,1,1,c,c,e,tp):GetFirst()
	-- 给对方玩家确认选择的怪兽
	Duel.ConfirmCards(1-tp,sc)
	-- 洗切手牌
	Duel.ShuffleHand(tp)
	sc:CreateEffectRelation(e)
	e:SetLabelObject(sc)
end
-- 效果①的发动准备（Target）处理函数，检查怪兽区域空位并设置操作信息
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用于特殊召唤的怪兽区域空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	-- 设置连锁中的操作信息：从手牌除外1张卡
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_HAND)
	-- 设置连锁中的操作信息：从手牌特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果①的效果处理（Operation）函数，处理特殊召唤、除外以及后续的额外卡组特召限制和攻击限制
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local sc=e:GetLabelObject()
	local g=Group.FromCards(c,sc)
	local fg=g:Filter(Card.IsRelateToEffect,nil,e)
	if fg:GetCount()==2 then
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=fg:FilterSelect(tp,s.tgspfilter,1,1,nil,fg,e,tp)
		-- 如果成功特殊召唤了选择的其中1只怪兽
		if #sg>0 and Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)>0 then
			-- 将另外1只怪兽除外
			Duel.Remove(g-sg,POS_FACEUP,REASON_EFFECT)
		end
	end
	-- 这个效果的发动后，直到回合结束时自己不是同调怪兽不能从额外卡组特殊召唤
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册限制自己不能从额外卡组特殊召唤同调怪兽以外怪兽的玩家效果
	Duel.RegisterEffect(e1,tp)
	-- 不用同调怪兽不能攻击宣言。把这张卡作为同调素材的场合，不是8星以下的怪兽的同调召唤不能使用。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(s.atktg)
	e2:SetReset(RESET_PHASE+PHASE_END)
	-- 注册限制自己不用同调怪兽不能攻击宣言的玩家效果
	Duel.RegisterEffect(e2,tp)
end
-- 限制从额外卡组特殊召唤的怪兽必须是同调怪兽
function s.splimit(e,c)
	return c:IsLocation(LOCATION_EXTRA) and not c:IsType(TYPE_SYNCHRO)
end
-- 限制不能进行攻击宣言的怪兽为同调怪兽以外的怪兽
function s.atktg(e,c)
	return not c:IsType(TYPE_SYNCHRO)
end
-- 限制作为同调素材时，不能用于8星以下以外的怪兽（即只能用于8星以下怪兽）的同调召唤
function s.synlimit(e,c)
	if not c then return false end
	return not c:IsLevelBelow(8)
end
