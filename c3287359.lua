--魔弾の悪魔 カスパール
-- 效果：
-- 包含恶魔族·光属性怪兽的怪兽2只
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡连接召唤的场合才能发动。从手卡·卡组选包含怪兽的2张「魔弹」卡，那之内的1只怪兽在自己场上特殊召唤，另1张在对方场上盖放。
-- ②：只要这张卡在怪兽区域存在，自己·对方回合自己可以把「魔弹」魔法·陷阱卡从手卡发动。
local s,id,o=GetID()
-- 初始化效果，设置连接召唤手续、启用复活限制，并注册①②两个效果
function s.initial_effect(c)
	-- 设置连接召唤需要2只满足s.lcheck条件的怪兽作为素材
	aux.AddLinkProcedure(c,nil,2,2,s.lcheck)
	c:EnableReviveLimit()
	-- ①：这张卡连接召唤的场合才能发动。从手卡·卡组选包含怪兽的2张「魔弹」卡，那之内的1只怪兽在自己场上特殊召唤，另1张在对方场上盖放。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"发动"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_SSET+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：只要这张卡在怪兽区域存在，自己·对方回合自己可以把「魔弹」魔法·陷阱卡从手卡发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"适用「魔弹恶魔 卡斯帕」的效果来发动"
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_QP_ACT_IN_NTPHAND)
	e2:SetRange(LOCATION_MZONE)
	-- 设置效果适用对象为「魔弹」卡
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x108))
	e2:SetTargetRange(LOCATION_HAND,0)
	e2:SetValue(32841045)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	c:RegisterEffect(e3)
end
-- 定义连接召唤时满足条件的怪兽数量和类型
function s.lcheck(g)
	return g:IsExists(s.mfilter,1,nil)
end
-- 定义满足条件的怪兽必须同时具有恶魔族和光属性
function s.mfilter(c)
	return c:IsLinkRace(RACE_FIEND) and c:IsLinkAttribute(ATTRIBUTE_LIGHT)
end
-- 判断此卡是否为连接召唤成功
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- 判断目标卡是否可以特殊召唤或盖放
function s.setfilter(c,e,tp)
	if c:IsType(TYPE_MONSTER) then
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		return not Duel.IsPlayerAffectedByEffect(tp,59822133)
			-- 判断对方场上是否有怪兽区域空位
			and Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0
			and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE,1-tp)
	else
		-- 判断对方场上是否有魔陷区域空位
		return (Duel.GetLocationCount(1-tp,LOCATION_SZONE)>0
			or c:IsType(TYPE_FIELD))
			and c:IsSSetable(true)
	end
end
-- 判断目标卡是否可以特殊召唤且满足s.setfilter条件
function s.spfilter(c,g,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
		and g:IsExists(s.setfilter,1,c,e,tp)
end
-- 判断所选卡组中是否存在满足s.spfilter条件的组合
function s.gcheck(g,e,tp)
	return g:IsExists(s.spfilter,1,nil,g,e,tp)
end
-- 设置效果发动时的处理目标
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检索满足「魔弹」条件的卡
	local g=Duel.GetMatchingGroup(Card.IsSetCard,tp,LOCATION_DECK+LOCATION_HAND,0,nil,0x108)
	-- 判断自己场上是否有怪兽区域空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and g:CheckSubGroup(s.gcheck,2,2,e,tp) end
	-- 设置连锁操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_HAND)
end
-- 处理效果发动时的特殊召唤和盖放操作
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断自己场上是否有怪兽区域空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 检索满足「魔弹」条件的卡
	local g=Duel.GetMatchingGroup(Card.IsSetCard,tp,LOCATION_DECK+LOCATION_HAND,0,nil,0x108)
	if not g:CheckSubGroup(s.gcheck,2,2,e,tp) then return end
	-- 提示选择效果对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	local tg=g:SelectSubGroup(tp,s.gcheck,false,2,2,e,tp)
	if tg:GetCount()>1 then
		-- 提示选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=tg:FilterSelect(tp,s.spfilter,1,1,nil,tg,e,tp)
		tg:Sub(sg)
		-- 将选中的卡特殊召唤到自己场上
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		local tc=tg:GetFirst()
		if tc:IsType(TYPE_MONSTER) then
			-- 将选中的卡特殊召唤到对方场上
			Duel.SpecialSummon(tc,0,tp,1-tp,false,false,POS_FACEDOWN_DEFENSE)
			-- 确认对方场上的卡
			Duel.ConfirmCards(tp,tc)
		else
			-- 将选中的卡在对方场上盖放
			Duel.SSet(tp,tc,1-tp)
		end
	end
end
