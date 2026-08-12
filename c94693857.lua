--ブンボーグ001
-- 效果：
-- ①：这张卡的攻击力·守备力上升自己场上的机械族怪兽数量×500。
-- ②：这张卡在墓地存在，场上有机械族怪兽2只以上同时特殊召唤的场合才能发动。这张卡特殊召唤。
function c94693857.initial_effect(c)
	-- 注册一个用于检测此卡是否已在墓地的效果，以确保在特殊召唤时能正确验证其在墓地的状态
	local e0=aux.AddThisCardInGraveAlreadyCheck(c)
	-- ①：这张卡的攻击力·守备力上升自己场上的机械族怪兽数量×500。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(c94693857.atkval)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e2)
	-- ②：这张卡在墓地存在，场上有机械族怪兽2只以上同时特殊召唤的场合才能发动。这张卡特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(94693857,0))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCountLimit(1,EFFECT_COUNT_CODE_CHAIN)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetLabelObject(e0)
	e3:SetCondition(c94693857.spcon)
	e3:SetTarget(c94693857.sptg)
	e3:SetOperation(c94693857.spop)
	c:RegisterEffect(e3)
end
-- 过滤条件：表侧表示的机械族怪兽，且排除由当前效果自身导致的特殊召唤
function c94693857.filter(c,se)
	return c:IsFaceup() and c:IsRace(RACE_MACHINE) and (se==nil or c:GetReasonEffect()~=se)
end
-- 计算攻击力/守备力上升值的函数，返回自己场上表侧表示的机械族怪兽数量乘以500
function c94693857.atkval(e,c)
	-- 获取自己场上表侧表示的机械族怪兽数量并乘以500
	return Duel.GetMatchingGroupCount(c94693857.filter,c:GetControler(),LOCATION_MZONE,0,nil)*500
end
-- 特殊召唤效果的发动条件：检测同时特殊召唤的怪兽中是否存在2只以上满足条件的机械族怪兽
function c94693857.spcon(e,tp,eg,ep,ev,re,r,rp)
	local se=e:GetLabelObject():GetLabelObject()
	return eg:IsExists(c94693857.filter,2,nil,se)
end
-- 特殊召唤效果的发动目标：检查自身是否能特殊召唤以及怪兽区域是否有空位，并设置特殊召唤的操作信息
function c94693857.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动效果前，检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁的操作信息，表明此效果包含将自身特殊召唤的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特殊召唤效果的处理：若此卡仍存在于墓地，则将其特殊召唤到自己场上
function c94693857.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将此卡以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
