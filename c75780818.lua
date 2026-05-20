--ダイナ・タンク
-- 效果：
-- 机械族怪兽＋恐龙族怪兽
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：这张卡的攻击力上升作为这张卡的融合素材的恐龙族怪兽的原本攻击力数值。
-- ②：只以场上的这1张卡为对象的效果发动时，以这张卡以外的场上1张卡为对象才能发动。那个对象转移为作为正确对象的那张卡。
-- ③：这张卡被对方破坏的场合才能发动。从自己墓地选1只恐龙族怪兽特殊召唤。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含融合素材设定、素材检查、攻击力上升、转移对象以及被破坏时特殊召唤的效果。
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 设定融合素材为机械族怪兽1只和恐龙族怪兽1只。
	aux.AddFusionProcFun2(c,aux.FilterBoolFunction(Card.IsRace,RACE_MACHINE),aux.FilterBoolFunction(Card.IsRace,RACE_DINOSAUR),true)
	-- ①：这张卡的攻击力上升作为这张卡的融合素材的恐龙族怪兽的原本攻击力数值。（素材检查部分）
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_MATERIAL_CHECK)
	e1:SetValue(s.valcheck)
	c:RegisterEffect(e1)
	-- ①：这张卡的攻击力上升作为这张卡的融合素材的恐龙族怪兽的原本攻击力数值。（特殊召唤成功时适用部分）
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(s.atkcon)
	e2:SetOperation(s.atkop)
	e2:SetLabelObject(e1)
	c:RegisterEffect(e2)
	-- ②：只以场上的这1张卡为对象的效果发动时，以这张卡以外的场上1张卡为对象才能发动。那个对象转移为作为正确对象的那张卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id)
	e3:SetCondition(s.cecon)
	e3:SetTarget(s.cetg)
	e3:SetOperation(s.ceop)
	c:RegisterEffect(e3)
	-- ③：这张卡被对方破坏的场合才能发动。从自己墓地选1只恐龙族怪兽特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_DESTROYED)
	e4:SetCountLimit(1,id+o)
	e4:SetCondition(s.spcon)
	e4:SetTarget(s.sptg)
	e4:SetOperation(s.spop)
	c:RegisterEffect(e4)
end
-- 检查融合素材，计算其中恐龙族怪兽的原本攻击力合计值并保存在Label中。
function s.valcheck(e,c)
	local g=c:GetMaterial()
	local atk=g:Filter(Card.IsRace,nil,RACE_DINOSAUR):GetSum(Card.GetBaseAttack)
	e:SetLabel(atk)
end
-- 检查这张卡是否是通过融合召唤特殊召唤成功的。
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
-- 攻击力上升效果的处理：使这张卡的攻击力上升融合素材中恐龙族怪兽的原本攻击力数值。
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local atk=e:GetLabelObject():GetLabel()
	if atk>0 then
		-- 这张卡的攻击力上升作为这张卡的融合素材的恐龙族怪兽的原本攻击力数值。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(atk)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end
-- 转移对象效果的发动条件：对方发动了只以场上的这张卡为对象的效果。
function s.cecon(e,tp,eg,ep,ev,re,r,rp)
	if e==re or not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	-- 获取当前连锁中被作为对象的所有卡片。
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	return g and g:GetCount()==1 and g:GetFirst()==e:GetHandler()
end
-- 过滤函数：检查卡片是否是当前连锁效果的正确对象。
function s.cefilter(c,ct)
	-- 检查卡片是否能作为当前连锁中效果的正确对象。
	return Duel.CheckChainTarget(ct,c)
end
-- 转移对象效果的靶向选择：选择场上1张除这张卡以外、且能作为该效果正确对象的卡。
function s.cetg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and s.cefilter(chkc,ev) and chkc~=e:GetHandler() end
	-- 检查场上是否存在至少1张除这张卡以外、且能作为该效果正确对象的卡。
	if chk==0 then return Duel.IsExistingTarget(s.cefilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler(),ev) end
	-- 给玩家发送提示信息，要求选择效果的对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 玩家选择1张除这张卡以外、且能作为该效果正确对象的卡作为本效果的对象。
	Duel.SelectTarget(tp,s.cefilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,e:GetHandler(),ev)
end
-- 转移对象效果的处理：将原本效果的对象转移为新选择的卡。
function s.ceop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本效果选择的转移目标卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将当前处理的连锁的对象修改为新选择的卡。
		Duel.ChangeTargetCard(ev,Group.FromCards(tc))
	end
end
-- 特殊召唤效果的发动条件：这张卡被对方破坏。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and e:GetHandler():IsPreviousControler(tp)
end
-- 过滤函数：检查卡片是否是恐龙族怪兽且可以被特殊召唤。
function s.spfilter(c,e,tp)
	return c:IsRace(RACE_DINOSAUR) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 特殊召唤效果的靶向选择：检查自己场上是否有空位，以及墓地是否存在可特殊召唤的恐龙族怪兽。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上的怪兽区域是否有空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在至少1只满足特殊召唤条件的恐龙族怪兽。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置连锁的操作信息，表示该效果包含从墓地特殊召唤1只怪兽的处理。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- 特殊召唤效果的处理：从自己墓地选择1只恐龙族怪兽特殊召唤。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有可用的怪兽区域，若无则不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 给玩家发送提示信息，要求选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家从自己墓地选择1只不受王家长眠之谷影响且满足条件的恐龙族怪兽。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
