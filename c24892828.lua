--ティスティナの還り仔
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡在手卡存在的场合，以「提斯蒂娜之还仔」以外的自己场上1只「提斯蒂娜」怪兽为对象才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡的等级变成和作为对象的怪兽相同。
-- ②：这张卡在墓地存在的场合，以自己场上1只水族超量怪兽为对象才能发动。把这张卡作为那只怪兽的超量素材。
local s,id,o=GetID()
-- 创建并注册这张卡的两个效果：①手牌中起动特殊召唤并变更等级的效果，②墓地中作为超量素材的效果。
function s.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。①：这张卡在手卡存在的场合，以「提斯蒂娜之还仔」以外的自己场上1只「提斯蒂娜」怪兽为对象才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡的等级变成和作为对象的怪兽相同。
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
	-- 这个卡名的①②的效果1回合各能使用1次。②：这张卡在墓地存在的场合，以自己场上1只水族超量怪兽为对象才能发动。把这张卡作为那只怪兽的超量素材。
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
-- ①效果的对象筛选条件：自己场上表侧表示、属于「提斯蒂娜」系列、有等级且卡名不是这张卡的怪兽。
function s.filter(c,code)
	return c:IsFaceup() and c:IsSetCard(0x1a4) and c:IsHasLevel() and not c:IsCode(code)
end
-- ①效果的发动目标判定：获取本卡及当前卡号，若为对象确认则验证对象合法性；若为发动条件检查则要求场上存在可特殊召唤的空位、本卡可特殊召唤、且存在满足条件的对象。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	local code=c:GetCode()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.filter(chkc,code) end
	-- 检查自己主要怪兽区是否有空位，作为①效果的发动条件之一。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查自己场上是否存在1只满足条件（表侧表示、提斯蒂娜系列、有等级、不是本卡）的怪兽，作为①效果的发动条件之一。
		and Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil,code) end
	-- 向玩家显示选择表侧表示卡片的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家从自己场上选择1只满足条件的「提斯蒂娜」怪兽作为①效果的对象，并记录为连锁对象。
	Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil,code)
	-- 设置操作信息：本效果将对这张卡进行特殊召唤，处理数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 处理①效果：将这张卡特殊召唤；若特殊召唤成功且对象仍相关并表侧表示，则使这张卡的等级变成对象等级。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取①效果选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) then
		-- 以表侧表示将这张卡特殊召唤，若成功则继续后续处理。
		if Duel.SpecialSummonStep(c,0,tp,tp,false,false,POS_FACEUP) then
			if tc:IsRelateToEffect(e) and tc:IsFaceup() then
				local lv=tc:GetLevel()
				-- 这个效果特殊召唤的这张卡的等级变成和作为对象的怪兽相同。
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_CHANGE_LEVEL)
				e1:SetValue(lv)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
				c:RegisterEffect(e1)
			end
		end
		-- 完成特殊召唤处理，正式结算特殊召唤。
		Duel.SpecialSummonComplete()
	end
end
-- ②效果的对象筛选条件：自己场上表侧表示的水族超量怪兽。
function s.ovfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_AQUA) and c:IsType(TYPE_XYZ)
end
-- ②效果的发动判定：若为对象确认则验证对象是否合法；若为发动条件检查则要求场上存在水族超量怪兽且本卡可以作为超量素材。
function s.ovtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.ovfilter(chkc) end
	-- 检查自己场上是否存在1只水族超量怪兽，作为②效果的发动条件之一。
	if chk==0 then return Duel.IsExistingTarget(s.ovfilter,tp,LOCATION_MZONE,0,1,nil)
		and e:GetHandler():IsCanOverlay() end
	-- 向玩家显示选择效果对象的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让玩家从自己场上选择1只水族超量怪兽作为②效果的对象，并记录为连锁对象。
	Duel.SelectTarget(tp,s.ovfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置操作信息：这张卡将从墓地离开，作为超量素材。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
-- 处理②效果：若这张卡和对象都仍与效果相关且对象不免疫此效果，则将这张卡作为对象超量怪兽的超量素材。
function s.ovop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取②效果选择的对象超量怪兽。
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e) then
		-- 把这张卡叠放在对象超量怪兽下方，作为其超量素材。
		Duel.Overlay(tc,c)
	end
end
