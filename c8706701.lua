--レッド・ミラー
-- 效果：
-- 「红莲镜」的①②的效果1回合各能使用1次。
-- ①：对方怪兽的攻击宣言时，把这张卡从手卡送去墓地，以「红莲镜」以外的自己墓地1只恶魔族·炎属性怪兽为对象才能发动。那只怪兽加入手卡。
-- ②：这张卡在墓地存在，自己同调召唤成功的场合才能发动。墓地的这张卡加入手卡。这个效果在这张卡送去墓地的回合不能发动。
function c8706701.initial_effect(c)
	-- ①：对方怪兽的攻击宣言时，把这张卡从手卡送去墓地，以「红莲镜」以外的自己墓地1只恶魔族·炎属性怪兽为对象才能发动。那只怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,8706701)
	e1:SetCondition(c8706701.condition)
	e1:SetCost(c8706701.cost)
	e1:SetTarget(c8706701.target)
	e1:SetOperation(c8706701.operation)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在，自己同调召唤成功的场合才能发动。墓地的这张卡加入手卡。这个效果在这张卡送去墓地的回合不能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,8706702)
	e2:SetCondition(c8706701.thcon)
	e2:SetTarget(c8706701.thtg)
	e2:SetOperation(c8706701.thop)
	c:RegisterEffect(e2)
end
-- e1效果的发动条件判定函数（对方怪兽攻击宣言时）
function c8706701.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判定攻击怪兽的控制者是否为对方玩家
	return Duel.GetAttacker():GetControler()~=tp
end
-- e1效果的发动代价处理函数（把这张卡从手卡送去墓地）
function c8706701.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将自身作为代价送去墓地
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 过滤自己墓地中「红莲镜」以外的恶魔族·炎属性且能加入手牌的怪兽
function c8706701.filter(c)
	return c:IsRace(RACE_FIEND) and c:IsAttribute(ATTRIBUTE_FIRE) and not c:IsCode(8706701) and c:IsAbleToHand()
end
-- e1效果的发动目标选择与检测函数（选择墓地中1只符合条件的怪兽为对象）
function c8706701.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c8706701.filter(chkc) end
	-- 在发动检测阶段，判断自己墓地是否存在至少1只符合条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(c8706701.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择自己墓地1只符合条件的怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c8706701.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置效果处理信息为“将选中的对象卡片加入手牌”
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- e1效果的执行函数（将对象怪兽加入手牌）
function c8706701.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为对象的卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽加入持有者的手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
-- 过滤由自己同调召唤成功的怪兽
function c8706701.cfilter(c,tp)
	return c:IsSummonType(SUMMON_TYPE_SYNCHRO) and c:IsSummonPlayer(tp)
end
-- e2效果的发动条件判定函数（自己同调召唤成功且这张卡不是在本回合被送去墓地）
function c8706701.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定是否有自己同调召唤成功的怪兽，并判定这张卡是否不是在本回合送去墓地
	return eg:IsExists(c8706701.cfilter,1,nil,tp) and aux.exccon(e)
end
-- e2效果的发动目标检测与处理信息设置函数（墓地的这张卡加入手卡）
function c8706701.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	-- 设置效果处理信息为“将墓地的这张卡加入手牌”
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- e2效果的执行函数（墓地的这张卡加入手卡）
function c8706701.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将墓地的这张卡加入持有者的手牌
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end
