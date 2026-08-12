--プリンシパグ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以原本卡名包含「守护者」的自己场上1只不能通常召唤的怪兽为对象才能发动。这个回合，那只怪兽在同1次的战斗阶段中可以作2次攻击。
-- ②：可以把墓地的这张卡除外，以自己墓地1只不能通常召唤的「守护者」怪兽为对象，从以下效果选择1个发动。
-- ●作为对象的怪兽加入手卡。
-- ●把1张在作为对象的怪兽有卡名记述的卡从自己墓地加入手卡。
local s,id,o=GetID()
-- 初始化卡片效果：注册①在场上发动的取对象起动效果（1回合1次，主要阶段或战斗阶段可发动，使对象怪兽可2次攻击），以及②在墓地发动的两个取对象起动效果分支（1回合合计1次，代价是除外这张卡，分别回收对象怪兽或回收记载其卡名的卡）
function s.initial_effect(c)
	-- ①：以原本卡名包含「守护者」的自己场上1只不能通常召唤的怪兽为对象才能发动。这个回合，那只怪兽在同1次的战斗阶段中可以作2次攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	-- 设置发动条件：玩家可以进入战斗阶段或正处于战斗阶段时才能发动
	e1:SetCondition(aux.bpcon)
	e1:SetTarget(s.bttg)
	e1:SetOperation(s.btop)
	c:RegisterEffect(e1)
	-- ②：可以把墓地的这张卡除外，以自己墓地1只不能通常召唤的「守护者」怪兽为对象，从以下效果选择1个发动。●作为对象的怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"作为对象的怪兽加入手卡"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	-- 设置发动代价：把墓地的这张卡除外
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.thtg1)
	e2:SetOperation(s.thop1)
	c:RegisterEffect(e2)
	-- ②：可以把墓地的这张卡除外，以自己墓地1只不能通常召唤的「守护者」怪兽为对象，从以下效果选择1个发动。●把1张在作为对象的怪兽有卡名记述的卡从自己墓地加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"作为对象的怪兽有卡名记述的卡加入手卡"
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,id+o)
	-- 设置发动代价：把墓地的这张卡除外
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(s.thtg2)
	e3:SetOperation(s.thop2)
	c:RegisterEffect(e3)
end
-- 过滤函数：检查怪兽是否表侧表示、不能通常召唤、属于「守护者」系列且尚未获得额外攻击次数
function s.bfilter(c)
	return c:IsFaceup() and not c:IsSummonableCard() and c:IsSetCard(0x52) and not c:IsHasEffect(EFFECT_EXTRA_ATTACK)
end
-- ①效果的对象处理：选择自己场上1只表侧表示的不能通常召唤的「守护者」怪兽作为效果对象
function s.bttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.bfilter(chkc) end
	-- 发动条件判定：自己场上是否存在可以成为对象的满足条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(s.bfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向玩家提示“请选择效果的对象”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让玩家选择自己场上1只满足条件的怪兽并将其设为效果对象
	Duel.SelectTarget(tp,s.bfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- ①效果处理：给对象怪兽赋予本回合额外攻击1次的能力（同1次战斗阶段中可作2次攻击），效果在结束阶段时重置
function s.btop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁的效果对象（那只怪兽）
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 这个回合，那只怪兽在同1次的战斗阶段中可以作2次攻击。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EXTRA_ATTACK)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
-- 过滤函数：检查墓地的卡是否可以加入手卡且其卡名被记载在指定怪兽的效果文本上
function s.thfilter(c,mc)
	-- 该卡可以加入手卡，且其卡名记载于对象怪兽的效果文本中
	return c:IsAbleToHand() and aux.IsCodeListed(mc,c:GetCode())
end
-- 过滤函数：检查墓地的卡是否为不能通常召唤的「守护者」怪兽；若需额外校验（check为真）则还要求墓地存在记载其卡名且可加入手卡的卡，否则只要求该怪兽可以加入手卡
function s.tgfilter(c,check,tp)
	if c:IsSummonableCard() or not c:IsSetCard(0x52) or not c:IsType(TYPE_MONSTER) then
		return false
	else
		if check then
			-- 检查自己墓地是否存在1张在作为对象的怪兽有卡名记述且可以加入手卡的卡
			return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE,0,1,nil,c)
		else
			return c:IsAbleToHand()
		end
	end
end
-- ②效果分支一的对象处理：以自己墓地1只不能通常召唤的「守护者」怪兽为对象，并设置回手卡的操作信息
function s.thtg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.tgfilter(chkc) end
	-- 发动条件判定：自己墓地是否存在可以成为对象的满足条件的怪兽（自身除外）
	if chk==0 then return Duel.IsExistingTarget(s.tgfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler()) end
	-- 向玩家提示“请选择要加入手牌的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家选择自己墓地1只满足条件的怪兽并将其设为效果对象
	local g=Duel.SelectTarget(tp,s.tgfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置操作信息：本次连锁将把1张确定的卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- ②效果分支一的效果处理：将作为对象的墓地怪兽加入手卡
function s.thop1(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁的效果对象（墓地的那只「守护者」怪兽）
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	-- 将作为对象的怪兽以效果处理加入持有者手卡
	Duel.SendtoHand(tc,nil,REASON_EFFECT)
end
-- ②效果分支二的对象处理：以自己墓地1只不能通常召唤且墓地存在记载其卡名的卡的「守护者」怪兽为对象，并设置回手卡的操作信息
function s.thtg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.tgfilter(chkc,true,tp) end
	-- 发动条件判定：自己墓地是否存在可以成为对象且墓地存在记载其卡名的卡的满足条件怪兽（自身除外）
	if chk==0 then return Duel.IsExistingTarget(s.tgfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler(),true,tp) end
	-- 向玩家提示“请选择要加入手牌的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家选择自己墓地1只满足条件的怪兽并将其设为效果对象
	local g=Duel.SelectTarget(tp,s.tgfilter,tp,LOCATION_GRAVE,0,1,1,nil,true,tp)
	-- 设置操作信息：本次连锁将把1张确定的卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- ②效果分支二的效果处理：从自己墓地选1张在作为对象的怪兽有卡名记述的卡加入手卡
function s.thop2(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁的效果对象（墓地的那只「守护者」怪兽）
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	-- 向玩家提示“请选择要加入手牌的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从自己墓地选择1张在作为对象的怪兽有卡名记述的卡
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil,tc)
	if g:GetCount()>0 then
		-- 把选择的卡以效果处理加入自己手卡
		Duel.SendtoHand(g,tp,REASON_EFFECT)
	end
end
