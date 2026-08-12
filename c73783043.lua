--レアル・ジェネクス・アクセラレーター
-- 效果：
-- ①：这张卡在怪兽区域存在的状态，「次世代」怪兽从自己卡组加入手卡时，把那之内的1只给对方观看才能发动。给人观看的怪兽特殊召唤。
function c73783043.initial_effect(c)
	-- ①：这张卡在怪兽区域存在的状态，「次世代」怪兽从自己卡组加入手卡时，把那之内的1只给对方观看才能发动。给人观看的怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(73783043,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetRange(LOCATION_MZONE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_TO_HAND)
	e1:SetTarget(c73783043.sptg)
	e1:SetOperation(c73783043.spop)
	c:RegisterEffect(e1)
end
-- 过滤从自己卡组加入自己手牌且未公开的、可以特殊召唤的「次世代」怪兽
function c73783043.filter(c,e,tp)
	return c:IsSetCard(0x2) and c:IsControler(tp) and not c:IsPublic()
		and c:IsPreviousLocation(LOCATION_DECK) and c:IsPreviousControler(tp)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动的目标与代价处理：确认是否有符合条件的怪兽加入手牌，并让玩家选择其中1只给对方观看作为发动代价，并将其设为效果处理对象
function c73783043.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有空怪兽位，以及加入手牌的卡中是否存在满足条件的「次世代」怪兽
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and eg:IsExists(c73783043.filter,1,nil,e,tp) end
	local g=eg:Filter(c73783043.filter,nil,e,tp)
	if g:GetCount()==1 then
		-- 给对方玩家确认加入手牌的那1只「次世代」怪兽
		Duel.ConfirmCards(1-tp,g)
		-- 洗切自己手牌
		Duel.ShuffleHand(tp)
		-- 将该怪兽设置为效果处理的对象
		Duel.SetTargetCard(g)
	else
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 给对方玩家确认选中的那1只「次世代」怪兽
		Duel.ConfirmCards(1-tp,sg)
		-- 洗切自己手牌
		Duel.ShuffleHand(tp)
		-- 将选中的怪兽设置为效果处理的对象
		Duel.SetTargetCard(sg)
	end
	-- 设置连锁信息，表示该效果包含从手牌特殊召唤1只怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果处理：将作为对象的那只给对方观看过的怪兽特殊召唤
function c73783043.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有空怪兽位，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 获取作为效果处理对象的那只怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将该怪兽在自己场上表侧表示特殊召唤
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
