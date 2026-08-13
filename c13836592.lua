--百戦王 ベヒーモス
-- 效果：
-- 这张卡可以把1只怪兽解放作上级召唤。
-- ①：这张卡召唤·特殊召唤的场合，以自己墓地1只兽族·兽战士族·鸟兽族怪兽为对象才能发动。那只怪兽加入手卡，这张卡的攻击力下降700。
-- ②：通常召唤的这张卡不受特殊召唤的怪兽发动的效果影响。
-- ③：自己结束阶段才能发动。这张卡的攻击力上升700。
local s,id,o=GetID()
-- 该函数为卡片注册全部效果：e1/e2为“把1只怪兽解放作上级召唤”的召唤规则效果（包含放置规则）；e3/e4实现①召唤·特殊召唤时回收墓地兽族·兽战士族·鸟兽族怪兽并下降700攻击；e5实现②通常召唤时不受特殊召唤怪兽发动的效果影响；e6实现③自己结束阶段攻击力上升700。
function s.initial_effect(c)
	-- 这张卡可以把1只怪兽解放作上级召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"把1只怪兽解放作上级召唤"
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCondition(s.otcon)
	e1:SetOperation(s.otop)
	e1:SetValue(SUMMON_TYPE_ADVANCE)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_SET_PROC)
	c:RegisterEffect(e2)
	-- ①：这张卡召唤·特殊召唤的场合，以自己墓地1只兽族·兽战士族·鸟兽族怪兽为对象才能发动。那只怪兽加入手卡，这张卡的攻击力下降700。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e4)
	-- ②：通常召唤的这张卡不受特殊召唤的怪兽发动的效果影响。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCode(EFFECT_IMMUNE_EFFECT)
	e5:SetValue(s.immval)
	c:RegisterEffect(e5)
	-- ③：自己结束阶段才能发动。这张卡的攻击力上升700。
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(id,3))
	e6:SetCategory(CATEGORY_ATKCHANGE)
	e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCode(EVENT_PHASE+PHASE_END)
	e6:SetCondition(s.atkcon)
	e6:SetOperation(s.atkop)
	c:RegisterEffect(e6)
end
-- 上级召唤规则效果的发动条件：c为nil时表示召唤动作本身可用；否则要求这张卡等级在9以上、需要解放的数量不超过1，且场上存在1只可解放的怪兽，以满足“把1只怪兽解放作上级召唤”。
function s.otcon(e,c,minc)
	if c==nil then return true end
	-- 判断是否满足上级召唤条件：这张卡等级≥9、所需解放数≤1、且场上存在1只可作为祭品的怪兽。
	return c:IsLevelAbove(9) and minc<=1 and Duel.CheckTribute(c,1)
end
-- 上级召唤规则的操作：让玩家选择1只解放的怪兽，将其设为召唤素材并解放，从而完成这次上级召唤。
function s.otop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 让这张卡的控制者选择用于上级召唤的1只祭品怪兽。
	local g=Duel.SelectTribute(tp,c,1,1)
	c:SetMaterial(g)
	-- 将选中的祭品怪兽以“上级召唤的解放”原因解放，作为召唤素材。
	Duel.Release(g,REASON_SUMMON+REASON_MATERIAL)
end
-- ③效果的发劯条件：仅在自己的结束阶段（当前回合玩家＝这张卡的控制者）才能发动。
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回当前回合玩家是否等于这张卡的控制者，即是否为自己回合的结束阶段。
	return tp==Duel.GetTurnPlayer()
end
-- ③效果处理：若这张卡仍与效果相关且表侧表示，则让它攻击力上升700。
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 这张卡的攻击力上升700。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(700)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end
-- ①效果的目标选择与操作信息设置：选择自己墓地1只符合条件的兽族·兽战士族·鸟兽族怪兽作为对象，并将回手牌信息写入连锁。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.thfilter(chkc) end
	-- 发动确认：检查自己墓地是否存在至少1只符合条件的兽族·兽战士族·鸟兽族怪兽可以作为对象。
	if chk==0 then return Duel.IsExistingTarget(s.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 弹出“请选择要加入手牌的卡”的选择提示，引导玩家选择对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从自己墓地选择1只符合条件的兽族·兽战士族·鸟兽族怪兽作为本效果的对象。
	local g=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置本连锁的操作信息为“将对象卡加入手牌”，数量为选中的卡数，用于后续效果检测。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,#g,0,0)
end
-- ①效果处理：将对象怪兽加入手牌，并使这张卡的攻击力下降700。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() then
		-- 将对象怪兽加入其持有者的手牌（即本方手牌）。
		Duel.SendtoHand(tc,tp,REASON_EFFECT)
		-- 这张卡的攻击力下降700。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		e1:SetValue(-700)
		c:RegisterEffect(e1)
	end
end
-- 过滤函数：判断墓地卡片是否为兽族·兽战士族·鸟兽族怪兽，且可以被加入手牌。
function s.thfilter(c)
	return c:IsRace(RACE_BEAST+RACE_BEASTWARRIOR+RACE_WINDBEAST) and c:IsAbleToHand()
end
-- ②免疫的判定逻辑：只有“特殊召唤的怪兽所发动的、在怪兽区发动的怪兽效果”才会对这张“通常召唤”的卡无效；其他效果不影响它。
function s.immval(e,te)
	local tc=te:GetOwner()
	local c=e:GetHandler()
	return tc:IsSummonType(SUMMON_TYPE_SPECIAL) and c:IsSummonType(SUMMON_TYPE_NORMAL)
		and te:IsActiveType(TYPE_MONSTER) and te:IsActivated() and te:GetActivateLocation()==LOCATION_MZONE
end
