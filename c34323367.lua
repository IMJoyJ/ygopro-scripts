--Emウォーター・ダンサー
-- 效果：
-- ←2 【灵摆】 2→
-- 这个卡名的①②的灵摆效果1回合各能使用1次。
-- ①：自己场上有「娱乐法师」怪兽存在的场合才能发动。这张卡特殊召唤。
-- ②：自己或对方的怪兽的攻击宣言时，以场上1只攻击表示怪兽为对象才能发动。那只怪兽变成守备表示。
-- 【怪兽效果】
-- 这个卡名的①的怪兽效果1回合只能使用1次。
-- ①：这张卡灵摆召唤的场合才能发动。从自己的卡组·墓地把1张「融合」加入手卡。
-- ②：场上的这张卡被战斗·效果破坏的场合，以场上1只攻击表示怪兽为对象才能发动。那只怪兽变成守备表示。
local s,id,o=GetID()
-- 初始化效果注册：为这张卡添加灵摆属性，并依次注册4个效果（灵摆①特殊召唤自身、灵摆②攻击宣言时变更表示、怪兽①灵摆召唤成功时检索「融合」、怪兽②被破坏时变更表示）。
function s.initial_effect(c)
	-- 为这张卡追加灵摆怪兽基础属性（可进行灵摆召唤/发动灵摆卡）。
	aux.EnablePendulumAttribute(c)
	-- 这个卡名的①②的灵摆效果1回合各能使用1次。①：自己场上有「娱乐法师」怪兽存在的场合才能发动。这张卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：自己或对方的怪兽的攻击宣言时，以场上1只攻击表示怪兽为对象才能发动。那只怪兽变成守备表示。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"变更表现形式"
	e2:SetCategory(CATEGORY_POSITION)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.postg)
	e2:SetOperation(s.posop)
	c:RegisterEffect(e2)
	-- 这个卡名的①的怪兽效果1回合只能使用1次。①：这张卡灵摆召唤的场合才能发动。从自己的卡组·墓地把1张「融合」加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"检索「融合」"
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCountLimit(1,id+o*2)
	e3:SetCondition(s.thcon)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
	-- ②：场上的这张卡被战斗·效果破坏的场合，以场上1只攻击表示怪兽为对象才能发动。那只怪兽变成守备表示。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,3))  --"变更表现形式"
	e4:SetCategory(CATEGORY_POSITION)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_DESTROYED)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e4:SetCondition(s.poscon)
	e4:SetTarget(s.postg)
	e4:SetOperation(s.posop)
	c:RegisterEffect(e4)
end
-- 定义「娱乐法师」怪兽的过滤条件：表侧表示且持有「娱乐法师」字段（0xc6）。
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xc6)
end
-- e1发动条件：己方场上有表侧表示的「娱乐法师」怪兽存在。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查己方主要怪兽区是否存在至少1只满足s.cfilter的「娱乐法师」怪兽。
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- e1的发动目标判定：确认这张卡能被特殊召唤，且己方主要怪兽区有空位。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 若为发动判定阶段（chk==0），返回己方主要怪兽区是否有空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 登记连锁操作信息：本连锁将包含特殊召唤这张卡的处理，供时点/干扰效果检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- e1效果处理：若这张卡仍与发动时使用的效果相关联，则将其特殊召唤。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 执行特殊召唤：将这张卡以表侧攻击表示特殊召唤到己方主要怪兽区。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 定义取对象过滤条件：表侧攻击表示且可以变更表示形式的怪兽。
function s.filter(c)
	return c:IsPosition(POS_FACEUP_ATTACK) and c:IsCanChangePosition()
end
-- e2/e4取对象目标处理：先确认存在可成为对象的表侧攻击表示怪兽，再提示玩家选择1只。
function s.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.filter(chkc) end
	-- 若为发动判定阶段，返回场上是否存在至少1只满足s.filter的表侧攻击表示怪兽。
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 弹出选择提示：请选择要改变表示形式的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
	-- 令玩家从双方主要怪兽区选择1只满足条件的表侧攻击表示怪兽，并将其设为当前连锁的对象。
	Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- e2/e4效果处理：取得对象怪兽，若其仍与效果关联且不是守备表示，则将其变更为表侧守备表示。
function s.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中登记的1只对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and not tc:IsPosition(POS_DEFENSE) then
		-- 将对象怪兽的表示形式变更为表侧守备表示。
		Duel.ChangePosition(tc,POS_FACEUP_DEFENSE)
	end
end
-- e3发动条件：这张卡是以灵摆召唤方式成功特殊召唤。
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_PENDULUM)
end
-- 定义检索过滤条件：卡名是「融合」（24094653）且能够加入手牌。
function s.thfilter(c)
	return c:IsCode(24094653) and c:IsAbleToHand()
end
-- e3发动目标判定：确认己方卡组·墓地存在至少1张符合条件的「融合」，并登记回手牌操作信息。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 若为发动判定阶段，返回己方卡组·墓地是否存在至少1张符合条件的「融合」。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	-- 登记连锁操作信息：本效果将从卡组·墓地取1张卡加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- e3效果处理：从己方卡组·墓地选择1张满足检索条件且不受王家长眠之谷影响的「融合」加入手牌，并让对方确认。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出选择提示：请选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 令玩家从己方卡组·墓地选择1张满足条件且不受王家长眠之谷影响的「融合」。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡以效果原因加入其持有者的手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 把刚加入手牌的卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- e4发动条件：这张卡在场上存在时被战斗或效果破坏。
function s.poscon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsReason(REASON_BATTLE+REASON_EFFECT)
end
