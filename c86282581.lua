--E-HERO ダーク・ナイト
-- 效果：
-- 恶魔族怪兽＋战士族怪兽
-- 这张卡用「暗黑融合」的效果才能特殊召唤。
-- ①：对方场上的怪兽的攻击力下降作为这张卡的融合素材的怪兽的原本攻击力的合计数值。
-- ②：这张卡在同1次的战斗阶段中可以作2次攻击。
-- ③：特殊召唤的表侧表示的这张卡因对方从场上离开的场合，以自己墓地1只恶魔族·战士族怪兽为对象才能发动。那只怪兽守备表示特殊召唤。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含融合素材、特殊召唤限制、素材检查（降低攻击力）、追加攻击和离场特召效果。
function s.initial_effect(c)
	-- 将「暗黑融合」加入到此卡的关联卡片列表中。
	aux.AddCodeList(c,94820406)
	c:EnableReviveLimit()
	-- 设置融合素材为恶魔族怪兽和战士族怪兽各1只。
	aux.AddFusionProcFun2(c,aux.FilterBoolFunction(Card.IsRace,RACE_FIEND),aux.FilterBoolFunction(Card.IsRace,RACE_WARRIOR),true)
	-- 这张卡用「暗黑融合」的效果才能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置特殊召唤条件的限制函数为「暗黑融合」或「暗黑神召」的效果。
	e1:SetValue(aux.DarkFusionLimit)
	c:RegisterEffect(e1)
	-- ①：对方场上的怪兽的攻击力下降作为这张卡的融合素材的怪兽的原本攻击力的合计数值。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_MATERIAL_CHECK)
	e2:SetValue(s.matcheck)
	c:RegisterEffect(e2)
	-- ②：这张卡在同1次的战斗阶段中可以作2次攻击。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_EXTRA_ATTACK)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	-- ③：特殊召唤的表侧表示的这张卡因对方从场上离开的场合，以自己墓地1只恶魔族·战士族怪兽为对象才能发动。那只怪兽守备表示特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_LEAVE_FIELD)
	e4:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e4:SetCondition(s.spcon)
	e4:SetTarget(s.sptg)
	e4:SetOperation(s.spop)
	c:RegisterEffect(e4)
end
s.dark_calling=true
-- 融合素材检查函数，在融合召唤成功时，为自身注册一个降低对方场上怪兽攻击力的永续效果。
function s.matcheck(e,c)
	local ec=e:GetHandler()
	-- 对方场上的怪兽的攻击力下降作为这张卡的融合素材的怪兽的原本攻击力的合计数值。
	local e1=Effect.CreateEffect(ec)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetValue(s.atkval)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD)
	ec:RegisterEffect(e1)
end
-- 计算并返回作为融合素材的怪兽的原本攻击力合计数值的负值。
function s.atkval(e,c)
	local ec=e:GetHandler()
	local g=ec:GetMaterial()
	local atk=g:GetSum(Card.GetTextAttack)
	return -atk
end
-- 判定发动条件：特殊召唤的表侧表示的这张卡因对方的操作从自己场上离开。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_SPECIAL) and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousPosition(POS_FACEUP)
		and c:IsPreviousControler(tp) and c:GetReasonPlayer()==1-tp
end
-- 过滤自己墓地中可以守备表示特殊召唤的恶魔族或战士族怪兽。
function s.filter(c,e,tp)
	return c:IsRace(RACE_FIEND+RACE_WARRIOR) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 效果③的靶向与发动合法性检测函数，用于选择墓地的目标怪兽并设置特殊召唤的操作信息。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and s.filter(chkc,e,tp) end
	-- 检查当前玩家场上是否有可用的怪兽区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在满足条件的、可作为效果对象的恶魔族或战士族怪兽。
		and Duel.IsExistingTarget(s.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只满足条件的怪兽作为效果对象并进行锁定。
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置连锁信息，表明该效果包含将选中的1只怪兽特殊召唤的操作。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果③的执行函数，将选中的墓地怪兽守备表示特殊召唤。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动时选择的作为效果对象的怪兽。
	local tc=Duel.GetFirstTarget()
	-- 检查目标怪兽是否仍与效果相关联，且不受「王家长眠之谷」的影响。
	if tc:IsRelateToEffect(e) and aux.NecroValleyFilter()(tc) then
		-- 将目标怪兽以表侧守备表示特殊召唤到发动效果的玩家场上。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
