--奇術王 ムーン・スター
-- 效果：
-- 把这张卡作为同调素材的场合，不是暗属性怪兽的同调召唤不能使用。
-- ①：自己场上有调整存在的场合，这张卡可以从手卡特殊召唤。
-- ②：这张卡召唤·特殊召唤的场合，以自己的场上（表侧表示）·墓地1只怪兽为对象才能发动。这张卡的等级直到回合结束时变成和那只怪兽相同。这个效果的发动后，直到回合结束时自己不能作同调召唤以外的特殊召唤。
function c35058857.initial_effect(c)
	-- 把这张卡作为同调素材的场合，不是暗属性怪兽的同调召唤不能使用。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetValue(c35058857.synlimit)
	c:RegisterEffect(e1)
	-- 自己场上有调整存在的场合，这张卡可以从手卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(c35058857.spcon)
	c:RegisterEffect(e2)
	-- 这张卡召唤·特殊召唤的场合，以自己的场上（表侧表示）·墓地1只怪兽为对象才能发动。这张卡的等级直到回合结束时变成和那只怪兽相同。这个效果的发动后，直到回合结束时自己不能作同调召唤以外的特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(35058857,0))  --"等级变更"
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e3:SetTarget(c35058857.lvtg)
	e3:SetOperation(c35058857.lvop)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e4)
end
-- 当有怪兽作为同调素材时，若该怪兽不是暗属性，则不能进行同调召唤。
function c35058857.synlimit(e,c)
	if not c then return false end
	return not c:IsAttribute(ATTRIBUTE_DARK)
end
-- 检查场上是否存在表侧表示的调整怪兽。
function c35058857.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_TUNER)
end
-- 判断手牌特殊召唤的条件：场上存在空位且己方场上存在调整怪兽。
function c35058857.spcon(e,c)
	if c==nil then return true end
	-- 判断己方场上是否存在空位。
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		-- 判断己方场上是否存在至少1只调整怪兽。
		and Duel.IsExistingMatchingCard(c35058857.filter,c:GetControler(),LOCATION_MZONE,0,1,nil)
end
-- 用于筛选目标怪兽的过滤函数：目标怪兽必须为表侧表示或在墓地，且等级与当前怪兽不同且大于等于1。
function c35058857.lvfilter(c,lv)
	return (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE)) and not c:IsLevel(lv) and c:IsLevelAbove(1)
end
-- 设置效果的目标选择函数：选择己方场上或墓地的1只符合条件的怪兽作为对象。
function c35058857.lvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local lv=e:GetHandler():GetLevel()
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE+LOCATION_GRAVE) and c35058857.lvfilter(chkc,lv) end
	-- 判断是否满足选择目标的条件：己方场上或墓地存在至少1只符合条件的怪兽。
	if chk==0 then return Duel.IsExistingTarget(c35058857.lvfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,nil,lv) end
	-- 向玩家发送提示信息“请选择效果的对象”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择符合条件的目标怪兽。
	Duel.SelectTarget(tp,c35058857.lvfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,1,nil,lv)
end
-- 处理效果的发动：将当前怪兽等级更改为所选目标怪兽的等级，并禁止在本回合进行除同调召唤外的特殊召唤。
function c35058857.lvop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果选择的目标怪兽。
	local tc=Duel.GetFirstTarget()
	local c=e:GetHandler()
	if tc:IsRelateToEffect(e) and c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 将当前怪兽的等级更改为所选目标怪兽的等级。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(tc:GetLevel())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
	-- 禁止在本回合进行除同调召唤外的特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,0)
	e2:SetReset(RESET_PHASE+PHASE_END)
	e2:SetTarget(c35058857.splimit)
	-- 将效果注册给指定玩家。
	Duel.RegisterEffect(e2,tp)
end
-- 判断召唤类型是否为同调召唤，若不是则禁止特殊召唤。
function c35058857.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return bit.band(sumtype,SUMMON_TYPE_SYNCHRO)~=SUMMON_TYPE_SYNCHRO
end
