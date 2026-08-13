--EMラフメイカー
-- 效果：
-- ←5 【灵摆】 5→
-- ①：1回合1次，对方场上有持有比原本攻击力高的攻击力的怪兽存在的场合才能发动。自己回复1000基本分。
-- 【怪兽效果】
-- 「娱乐伙伴 逗乐家」的①②的怪兽效果1回合只能有1次使用其中任意1个。
-- ①：这张卡的攻击宣言时才能发动。这张卡的攻击力直到战斗阶段结束时上升这张卡以及对方场上的怪兽之内持有比原本攻击力高的攻击力的怪兽数量×1000。
-- ②：持有比原本攻击力高的攻击力的这张卡被战斗·效果破坏的场合，以自己墓地1只怪兽为对象才能发动。那只怪兽特殊召唤。
function c44944304.initial_effect(c)
	-- 为这张灵摆怪兽注册灵摆怪兽属性：使其可以放置在灵摆区作为灵摆卡发动，并能进行灵摆召唤。
	aux.EnablePendulumAttribute(c)
	-- ①：1回合1次，对方场上有持有比原本攻击力高的攻击力的怪兽存在的场合才能发动。自己回复1000基本分。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(44944304,0))
	e1:SetCategory(CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCountLimit(1)
	e1:SetCondition(c44944304.rccon)
	e1:SetTarget(c44944304.rctg)
	e1:SetOperation(c44944304.rcop)
	c:RegisterEffect(e1)
	-- 「娱乐伙伴 逗乐家」的①②的怪兽效果1回合只能有1次使用其中任意1个。①：这张卡的攻击宣言时才能发动。这张卡的攻击力直到战斗阶段结束时上升这张卡以及对方场上的怪兽之内持有比原本攻击力高的攻击力的怪兽数量×1000。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(44944304,1))
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetCountLimit(1,44944304)
	e2:SetCondition(c44944304.atkcon)
	e2:SetOperation(c44944304.atkop)
	c:RegisterEffect(e2)
	-- 「娱乐伙伴 逗乐家」的①②的怪兽效果1回合只能有1次使用其中任意1个。②：持有比原本攻击力高的攻击力的这张卡被战斗·效果破坏的场合，以自己墓地1只怪兽为对象才能发动。那只怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(44944304,2))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetCountLimit(1,44944304)
	e3:SetCondition(c44944304.spcon)
	e3:SetTarget(c44944304.sptg)
	e3:SetOperation(c44944304.spop)
	c:RegisterEffect(e3)
end
-- 怪兽过滤器：判断卡是否表侧表示且当前攻击力高于原本攻击力（满足“持有比原本攻击力高的攻击力”）。
function c44944304.rcfilter(c)
	return c:IsFaceup() and c:GetAttack()>c:GetBaseAttack()
end
-- 灵摆效果①的发动条件：对方场上存在至少1只表侧表示且攻击力高于原本攻击力的怪兽。
function c44944304.rccon(e,tp,eg,ep,ev,re,r,rp)
	-- 检索对方场上怪兽区域是否存在至少1张满足 rcfilter 的卡。
	return Duel.IsExistingMatchingCard(c44944304.rcfilter,tp,0,LOCATION_MZONE,1,nil)
end
-- 回复效果的发动时目标处理：不取对象，设定回复对象为发动玩家自己、回复数值为1000，并登记回复操作信息。
function c44944304.rctg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将当前连锁的对象玩家设为发动者自己（自己回复）。
	Duel.SetTargetPlayer(tp)
	-- 将当前连锁的对象参数设为1000，表示回复的数值。
	Duel.SetTargetParam(1000)
	-- 登记操作信息：本连锁是回复效果，回复玩家 tp 回复1000点基本分，供后续判定使用。
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,1000)
end
-- 回复效果的处理：从连锁信息中取出对象玩家与回复数值，让该玩家回复相应基本分。
function c44944304.rcop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中记录的对象玩家和对象参数，分别保存为 p 和 d。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果原因令玩家 p 回复 d 点基本分。
	Duel.Recover(p,d,REASON_EFFECT)
end
-- 攻击宣言时效果①的发动条件：这张卡本身满足“攻击力高于原本攻击力”，或对方场上有满足该条件的怪兽存在。
function c44944304.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 条件判断：自身当前攻击力高于原本攻击力，或者对方怪兽区存在至少1张满足 rcfilter 的卡。
	return c44944304.rcfilter(e:GetHandler()) or Duel.IsExistingMatchingCard(c44944304.rcfilter,tp,0,LOCATION_MZONE,1,nil)
end
-- 攻击力上升效果的处理：计算符合条件的怪兽数量（对方场上的加上这张卡自身），给这张卡附加攻击力上升数值并持续到战斗阶段结束。
function c44944304.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToBattle() or c:IsFacedown() then return end
	-- 统计对方场上满足“表侧表示且攻击力高于原本攻击力”的怪兽数量。
	local ct=Duel.GetMatchingGroupCount(c44944304.rcfilter,tp,0,LOCATION_MZONE,nil)
	if c44944304.rcfilter(c) then ct=ct+1 end
	if ct>0 then
		-- 创建使这张卡攻击力上升 1000×ct 的永续型单体效果，并在战斗阶段结束时重置，对应其攻击力上升效果。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(1000*ct)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE)
		c:RegisterEffect(e1)
	end
end
-- 破坏时特殊召唤效果的发动条件：这张卡因战斗或效果被破坏，且破坏前位于怪兽区域，并且在场时的攻击力高于原本攻击力。
function c44944304.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_EFFECT+REASON_BATTLE) and c:IsPreviousLocation(LOCATION_MZONE) and c:GetPreviousAttackOnField()>c:GetBaseAttack()
end
-- 特殊召唤对象过滤器：判断墓地中的怪兽能否以通常规则被特殊召唤（检查召唤条件和苏生限制）。
function c44944304.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 取对象阶段确认：当系统用 chkc 检查候选对象时，要求该卡在自己墓地且可以被特殊召唤。
function c44944304.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp)
		and chkc:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 发动合法性检查：自己场上主要怪兽区存在可用空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且自己墓地中存在至少1张可以成为本效果对象并被特殊召唤的怪兽。
		and Duel.IsExistingTarget(c44944304.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 给玩家弹出“请选择要特殊召唤的卡”的选择提示，并缓存选择信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己墓地选择1张满足 spfilter 的怪兽作为本连锁的对象，同时登记为取对象。
	local g=Duel.SelectTarget(tp,c44944304.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 登记操作信息：本连锁的效果将特殊召唤对象卡 g（数量1）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 特殊召唤处理：取得对象怪兽，若仍与该效果关联（未被无效等），将其特殊召唤到自己场上。
function c44944304.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的第一个对象卡（所选的墓地怪兽）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽以表侧攻击表示特殊召唤到玩家 tp 的场上，并遵守通常的召唤条件与苏生限制。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
