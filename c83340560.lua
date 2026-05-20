--偉大なるダブルキャスター
-- 效果：
-- 效果怪兽以外的怪兽×2
-- 这个卡名的③的效果1回合只能使用1次。
-- ①：这张卡的攻击力上升作为这张卡的融合素材的仪式·融合·同调·超量·连接怪兽的原本攻击力的合计数值。
-- ②：这张卡可以直接攻击。
-- ③：这张卡被战斗·效果破坏的场合，从自己墓地的怪兽以及除外的自己怪兽之中以效果怪兽以外的1只怪兽为对象才能发动。那只怪兽特殊召唤。
local s,id,o=GetID()
-- 注册卡片效果：融合召唤手续、融合素材检查、特殊召唤成功时攻击力上升、直接攻击、被破坏时特殊召唤。
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加融合召唤手续：需要2只效果怪兽以外的怪兽作为融合素材。
	aux.AddFusionProcFunRep(c,s.noeff,2,true)
	-- ①：这张卡的攻击力上升作为这张卡的融合素材的仪式·融合·同调·超量·连接怪兽的原本攻击力的合计数值。（素材检查）
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_MATERIAL_CHECK)
	e1:SetValue(s.atkcalc)
	c:RegisterEffect(e1)
	-- ①：这张卡的攻击力上升作为这张卡的融合素材的仪式·融合·同调·超量·连接怪兽的原本攻击力的合计数值。（特殊召唤成功时适用）
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(s.atkcon)
	e2:SetOperation(s.atkop)
	e2:SetLabelObject(e1)
	c:RegisterEffect(e2)
	-- ②：这张卡可以直接攻击。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_DIRECT_ATTACK)
	c:RegisterEffect(e3)
	-- ③：这张卡被战斗·效果破坏的场合，从自己墓地的怪兽以及除外的自己怪兽之中以效果怪兽以外的1只怪兽为对象才能发动。那只怪兽特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e4:SetCode(EVENT_DESTROYED)
	e4:SetCountLimit(1,id)
	e4:SetCondition(s.spcon)
	e4:SetTarget(s.sptg)
	e4:SetOperation(s.spop)
	c:RegisterEffect(e4)
end
-- 过滤条件：判断卡片是否为效果怪兽以外的怪兽。
function s.noeff(c)
	return not c:IsFusionType(TYPE_EFFECT)
end
-- 融合素材检查：计算作为融合素材的仪式·融合·同调·超量·连接怪兽的原本攻击力合计值，并保存在效果的Label中。
function s.atkcalc(e,c)
	local g=c:GetMaterial()
	local atk=0
	-- 遍历融合素材卡片组。
	for tc in aux.Next(g) do
		if tc:IsFusionType(TYPE_RITUAL+TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ+TYPE_LINK) then
			atk=atk+tc:GetBaseAttack()
		end
	end
	e:SetLabel(atk)
end
-- 特殊召唤成功时效果的发动条件：这张卡融合召唤成功的场合。
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
-- 特殊召唤成功时效果的效果处理：使这张卡的攻击力上升之前计算并保存的原本攻击力合计值。
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local atk=e:GetLabelObject():GetLabel()
	if atk>0 then
		-- ①：这张卡的攻击力上升作为这张卡的融合素材的仪式·融合·同调·超量·连接怪兽的原本攻击力的合计数值。（增加攻击力数值）
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(atk)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end
-- 特殊召唤效果的发动条件：这张卡被战斗或效果破坏。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return r&(REASON_EFFECT+REASON_BATTLE)
end
-- 过滤条件：判断卡片是否为效果怪兽以外、在墓地或表侧除外且可以特殊召唤的怪兽。
function s.spfilter(c,e,tp)
	return s.noeff(c) and (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE)) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 特殊召唤效果的发动准备（检查是否满足发动条件、选择对象并设置操作信息）。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and chkc:IsControler(tp) and s.spfilter(chkc,e,tp) end
	-- 检查自己场上是否有空余的怪兽区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且自己墓地或除外状态的怪兽中存在至少1只满足特殊召唤条件的效果怪兽以外的怪兽。
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 给玩家发送提示信息：请选择要特殊召唤的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己墓地或除外的怪兽中选择1只效果怪兽以外的怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp)
	-- 设置特殊召唤的操作信息：包含特殊召唤分类、对象卡片组和数量。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 特殊召唤效果的效果处理（将选择的对象怪兽特殊召唤）。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择为效果对象的卡片。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
