--ティスティナの還り仔
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡在手卡存在的场合，以「提斯蒂娜之还仔」以外的自己场上1只「提斯蒂娜」怪兽为对象才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡的等级变成和作为对象的怪兽相同。
-- ②：这张卡在墓地存在的场合，以自己场上1只水族超量怪兽为对象才能发动。把这张卡作为那只怪兽的超量素材。
local s,id,o=GetID()
-- 创建两个效果，分别对应①和②效果，①效果在手牌发动，②效果在墓地发动
function s.initial_effect(c)
	-- ①：这张卡在手卡存在的场合，以「提斯蒂娜之还仔」以外的自己场上1只「提斯蒂娜」怪兽为对象才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡的等级变成和作为对象的怪兽相同。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的场合，以自己场上1只水族超量怪兽为对象才能发动。把这张卡作为那只怪兽的超量素材。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"作为超量素材"
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.ovtg)
	e2:SetOperation(s.ovop)
	c:RegisterEffect(e2)
end
-- 定义过滤函数，用于筛选场上的提斯蒂娜怪兽（不包括自身）
function s.filter(c,code)
	return c:IsFaceup() and c:IsSetCard(0x1a4) and c:IsHasLevel() and not c:IsCode(code)
end
-- ①效果的发动时点处理函数，判断是否满足发动条件并选择对象
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	local code=c:GetCode()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.filter(chkc,code) end
	-- 判断场上是否有足够的怪兽区域用于特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 判断场上是否存在符合条件的提斯蒂娜怪兽作为对象
		and Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil,code) end
	-- 提示玩家选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择符合条件的提斯蒂娜怪兽作为对象
	Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil,code)
	-- 设置效果处理信息，表示将要特殊召唤此卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- ①效果的处理函数，执行特殊召唤并改变等级
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) then
		-- 执行特殊召唤步骤
		if Duel.SpecialSummonStep(c,0,tp,tp,false,false,POS_FACEUP) then
			if tc:IsRelateToEffect(e) and tc:IsFaceup() then
				local lv=tc:GetLevel()
				-- 创建等级变更效果，使此卡等级变为对象怪兽的等级
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_CHANGE_LEVEL)
				e1:SetValue(lv)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
				c:RegisterEffect(e1)
			end
		end
		-- 完成特殊召唤流程
		Duel.SpecialSummonComplete()
	end
end
-- 定义过滤函数，用于筛选场上的水族超量怪兽
function s.ovfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_AQUA) and c:IsType(TYPE_XYZ)
end
-- ②效果的发动时点处理函数，判断是否满足发动条件并选择对象
function s.ovtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.ovfilter(chkc) end
	-- 判断场上是否存在符合条件的水族超量怪兽作为对象
	if chk==0 then return Duel.IsExistingTarget(s.ovfilter,tp,LOCATION_MZONE,0,1,nil)
		and e:GetHandler():IsCanOverlay() end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择符合条件的水族超量怪兽作为对象
	Duel.SelectTarget(tp,s.ovfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置效果处理信息，表示将要将此卡作为超量素材
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
-- ②效果的处理函数，执行将此卡作为超量素材的操作
function s.ovop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e) then
		-- 将此卡叠放在对象怪兽上作为超量素材
		Duel.Overlay(tc,c)
	end
end
