--アルカナフォースⅩⅤ－THE DEVIL
-- 效果：
-- ①：把这张卡从手卡丢弃才能发动。从自己的卡组·墓地把1张「光之结界」加入手卡。
-- ②：这张卡召唤·反转召唤·特殊召唤的场合发动。进行1次投掷硬币，那个里表让这张卡得到以下效果。
-- ●表：这张卡进行战斗的攻击宣言时，以场上1只怪兽为对象才能发动。那只怪兽破坏，给与那个控制者500伤害。
-- ●里：这张卡进行战斗的攻击宣言时发动。场上的怪兽全部破坏。
local s,id,o=GetID()
-- 注册卡片效果：①效果（手牌丢弃检索/回收「光之结界」）、硬币投掷效果、②表效果（攻击宣言时单体破坏并伤害）、②里效果（攻击宣言时全场破坏）
function s.initial_effect(c)
	-- 将「光之结界」（卡号73206827）记录在此卡的关联卡片列表中
	aux.AddCodeList(c,73206827)
	-- ①：把这张卡从手卡丢弃才能发动。从自己的卡组·墓地把1张「光之结界」加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCost(s.thcost)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- 注册秘仪之力系列通用的硬币投掷效果，在召唤、反转召唤、特殊召唤成功时强制发动
	aux.EnableArcanaCoin(c,EVENT_SUMMON_SUCCESS,EVENT_FLIP_SUMMON_SUCCESS,EVENT_SPSUMMON_SUCCESS)
	-- ●表：这张卡进行战斗的攻击宣言时，以场上1只怪兽为对象才能发动。那只怪兽破坏，给与那个控制者500伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCondition(s.odescon)
	e2:SetTarget(s.odestg)
	e2:SetOperation(s.odesop)
	c:RegisterEffect(e2)
	-- ●里：这张卡进行战斗的攻击宣言时发动。场上的怪兽全部破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,3))
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_ATTACK_ANNOUNCE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(s.fdescon)
	e3:SetTarget(s.fdestg)
	e3:SetOperation(s.fdesop)
	c:RegisterEffect(e3)
end
-- ①效果的发动代价（Cost）函数：检查并把这张卡从手卡丢弃
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsDiscardable() end
	-- 作为发动代价，将此卡从手卡丢弃送去墓地
	Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
end
-- 过滤条件：卡名为「光之结界」且能加入手牌
function s.filter(c)
	return c:IsCode(73206827) and c:IsAbleToHand()
end
-- ①效果的发动检测与效果分类注册（Target）函数
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动检测阶段，检查自己的卡组或墓地是否存在至少1张满足过滤条件的「光之结界」
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	-- 设置连锁信息，表示该效果的处理为从卡组或墓地将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- ①效果的效果处理（Operation）函数：从卡组或墓地选择1张「光之结界」加入手牌
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向发动玩家提示选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组或墓地选择1张满足条件的「光之结界」（受「王家长眠之谷」影响）
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.filter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		-- 将选择的卡片加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手牌的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
-- ②表效果的发动条件函数：此卡进行战斗的攻击宣言时，且硬币投掷结果为表（正面）
function s.odescon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查此卡是否参与战斗（作为攻击怪兽或被攻击怪兽），且硬币投掷结果为表（正面）
	return (Duel.GetAttacker()==c or Duel.GetAttackTarget()==c) and c:GetFlagEffectLabel(FLAG_ID_ARCANA_COIN)==1
end
-- ②表效果的发动检测与对象选择（Target）函数
function s.odestg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) end
	-- 在发动检测阶段，检查场上是否存在至少1只怪兽可以作为效果对象
	if chk==0 then return Duel.IsExistingTarget(nil,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向发动玩家提示选择要破坏的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家选择场上1只怪兽作为效果对象
	local g=Duel.SelectTarget(tp,nil,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置连锁信息，表示该效果的处理为破坏选中的怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置连锁信息，表示该效果的处理为给与对方500点伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,500)
end
-- ②表效果的效果处理（Operation）函数：破坏对象怪兽并给与其控制者500点伤害
function s.odesop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	-- 若对象怪兽仍存在于场上，则将其破坏；破坏成功时，给与其控制者500点伤害
	if tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)>0 then Duel.Damage(1-tp,500,REASON_EFFECT) end
end
-- ②里效果的发动条件函数：此卡进行战斗的攻击宣言时，且硬币投掷结果为里（反面）
function s.fdescon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查此卡是否参与战斗（作为攻击怪兽或被攻击怪兽），且硬币投掷结果为里（反面）
	return (Duel.GetAttacker()==c or Duel.GetAttackTarget()==c) and c:GetFlagEffectLabel(FLAG_ID_ARCANA_COIN)==0
end
-- ②里效果的发动检测与效果分类注册（Target）函数
function s.fdestg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取双方场上所有的怪兽
	local g=Duel.GetFieldGroup(tp,LOCATION_MZONE,LOCATION_MZONE)
	-- 设置连锁信息，表示该效果的处理为破坏场上的全部怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
-- ②里效果的效果处理（Operation）函数：破坏场上的全部怪兽
function s.fdesop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前场上所有的怪兽
	local g=Duel.GetFieldGroup(tp,LOCATION_MZONE,LOCATION_MZONE)
	-- 将获取到的场上所有怪兽全部破坏
	Duel.Destroy(g,REASON_EFFECT)
end
