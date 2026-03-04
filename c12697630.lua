--アーティファクト－ベガルタ
-- 效果：
-- 这张卡可以当作魔法卡使用从手卡到魔法与陷阱卡区域盖放。魔法与陷阱卡区域盖放的这张卡在对方回合被破坏送去墓地时，这张卡特殊召唤。对方回合中这张卡特殊召唤成功的场合，选自己场上盖放的最多2张卡破坏。「古遗物-微怒剑」的这个效果1回合只能使用1次。
function c12697630.initial_effect(c)
	-- 这张卡可以当作魔法卡使用从手卡到魔法与陷阱卡区域盖放。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_MONSTER_SSET)
	e1:SetValue(TYPE_SPELL)
	c:RegisterEffect(e1)
	-- 魔法与陷阱卡区域盖放的这张卡在对方回合被破坏送去墓地时，这张卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(12697630,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(c12697630.spcon)
	e2:SetTarget(c12697630.sptg)
	e2:SetOperation(c12697630.spop)
	c:RegisterEffect(e2)
	-- 对方回合中这张卡特殊召唤成功的场合，选自己场上盖放的最多2张卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(12697630,1))  --"破坏"
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCountLimit(1,12697630)
	e3:SetCondition(c12697630.descon)
	e3:SetTarget(c12697630.destg)
	e3:SetOperation(c12697630.desop)
	c:RegisterEffect(e3)
end
-- 检索满足条件的卡片组
function c12697630.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_SZONE) and c:IsPreviousPosition(POS_FACEDOWN)
		and c:IsPreviousControler(tp)
		-- 将目标怪兽特殊召唤
		and c:IsReason(REASON_DESTROY) and Duel.GetTurnPlayer()~=tp
end
-- 效果作用
function c12697630.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果作用
function c12697630.spop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 执行特殊召唤
		Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 效果作用
function c12697630.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否为对方回合
	return Duel.GetTurnPlayer()~=tp
end
-- 过滤函数，返回背面表示的卡
function c12697630.filter(c)
	return c:IsFacedown()
end
-- 效果作用
function c12697630.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取场上背面表示的卡
	local g=Duel.GetMatchingGroup(c12697630.filter,tp,LOCATION_ONFIELD,0,nil)
	if g:GetCount()>0 then
		-- 设置破坏的操作信息
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	end
end
-- 效果作用
function c12697630.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上背面表示的卡
	local g=Duel.GetMatchingGroup(c12697630.filter,tp,LOCATION_ONFIELD,0,nil)
	if g:GetCount()>0 then
		-- 提示选择要破坏的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local sg=g:Select(tp,1,2,nil)
		-- 破坏指定数量的卡
		Duel.Destroy(sg,REASON_EFFECT)
	end
end
