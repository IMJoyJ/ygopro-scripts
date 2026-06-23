--炎獣使いエーカ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤成功的场合，以自己或者对方的魔法与陷阱区域1张表侧表示的怪兽卡为对象才能发动。那张卡在自己场上特殊召唤。
-- ②：以这张卡以外的自己场上1只表侧表示怪兽为对象才能发动。那只表侧表示怪兽当作攻击力上升500的装备卡使用给这张卡装备。
function c35283277.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤成功的场合，以自己或者对方的魔法与陷阱区域1张表侧表示的怪兽卡为对象才能发动。那张卡在自己场上特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(35283277,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,35283277)
	e1:SetTarget(c35283277.sptg)
	e1:SetOperation(c35283277.spop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：以这张卡以外的自己场上1只表侧表示怪兽为对象才能发动。那只表侧表示怪兽当作攻击力上升500的装备卡使用给这张卡装备。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(35283277,1))
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,35283278)
	e3:SetTarget(c35283277.eqtg)
	e3:SetOperation(c35283277.eqop)
	c:RegisterEffect(e3)
end
-- 检索满足条件的魔法与陷阱区域的怪兽卡，用于特殊召唤
function c35283277.spfilter(c,e,tp)
	return c:IsFaceup() and c:GetSequence()<5 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 判断是否满足特殊召唤的条件，包括是否有足够的怪兽区域和是否存在符合条件的目标怪兽
function c35283277.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_SZONE) and c35283277.spfilter(chkc,e,tp) end
	-- 判断目标玩家是否有足够的怪兽区域用于特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断目标玩家的魔法与陷阱区域是否存在符合条件的怪兽卡
		and Duel.IsExistingTarget(c35283277.spfilter,tp,LOCATION_SZONE,LOCATION_SZONE,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择目标怪兽卡用于特殊召唤
	local g=Duel.SelectTarget(tp,c35283277.spfilter,tp,LOCATION_SZONE,LOCATION_SZONE,1,1,nil,e,tp)
	-- 设置连锁操作信息，确定特殊召唤的卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 处理特殊召唤效果，将目标怪兽特殊召唤到场上
function c35283277.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标怪兽卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽卡特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 检索满足条件的场上怪兽卡，用于装备
function c35283277.eqfilter(c,tp)
	return c:IsFaceup() and c:CheckUniqueOnField(tp,LOCATION_SZONE) and not c:IsForbidden()
end
-- 判断是否满足装备的条件，包括是否有足够的魔法与陷阱区域和是否存在符合条件的目标怪兽
function c35283277.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c35283277.eqfilter(chkc,tp) and chkc~=c end
	-- 判断目标玩家是否有足够的魔法与陷阱区域用于装备
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 判断目标玩家场上是否存在符合条件的怪兽卡
		and Duel.IsExistingTarget(c35283277.eqfilter,tp,LOCATION_MZONE,0,1,c,tp) end
	-- 提示玩家选择要装备的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择目标怪兽卡用于装备
	local g=Duel.SelectTarget(tp,c35283277.eqfilter,tp,LOCATION_MZONE,0,1,1,c,tp)
end
-- 处理装备效果，将目标怪兽装备给自身并设置攻击力加成
function c35283277.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的目标怪兽卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 尝试将目标怪兽装备给自身，若失败则返回
		if not Duel.Equip(tp,tc,c,false) then return end
		-- 设置装备对象限制，确保只能装备给自身
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_OWNER_RELATE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetLabelObject(c)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(c35283277.eqlimit)
		tc:RegisterEffect(e1)
		-- 设置装备卡的攻击力加成效果，使攻击力上升500
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_EQUIP)
		e2:SetCode(EFFECT_UPDATE_ATTACK)
		e2:SetValue(500)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
	end
end
-- 装备对象限制的判断函数，确保只能装备给自身
function c35283277.eqlimit(e,c)
	return c==e:GetLabelObject()
end
