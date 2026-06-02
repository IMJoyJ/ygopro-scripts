--ヴァレルロード・R・ドラゴン
-- 效果：
-- 「重型扳机」降临。这个卡名的①②的效果1回合各能使用1次。
-- ①：对方把怪兽特殊召唤之际才能发动。那次特殊召唤无效，那些怪兽破坏。那之后，选这张卡或者自己场上1只「弹丸」怪兽破坏。
-- ②：这张卡在墓地存在的场合，以自己墓地1只「枪管」怪兽或者「弹丸」怪兽为对象才能发动。选自己的手卡·场上1张卡破坏，作为对象的怪兽加入手卡。
function c7987191.initial_effect(c)
	-- 记录此卡有关联的卡片密码（重型扳机）
	aux.AddCodeList(c,20071842)
	c:EnableReviveLimit()
	-- ①：对方把怪兽特殊召唤之际才能发动。那次特殊召唤无效，那些怪兽破坏。那之后，选这张卡或者自己场上1只「弹丸」怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(7987191,0))
	e1:SetCategory(CATEGORY_DISABLE_SUMMON+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_SPSUMMON)
	e1:SetCountLimit(1,7987191)
	e1:SetCondition(c7987191.condition)
	e1:SetTarget(c7987191.target)
	e1:SetOperation(c7987191.operation)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的场合，以自己墓地1只「枪管」怪兽或者「弹丸」怪兽为对象才能发动。选自己的手卡·场上1张卡破坏，作为对象的怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(7987191,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,7987192)
	e2:SetTarget(c7987191.thtg)
	e2:SetOperation(c7987191.thop)
	c:RegisterEffect(e2)
end
-- 发动条件：对方进行特殊召唤之际，且当前不在连锁处理中
function c7987191.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查是否为对方进行特殊召唤，且不在连锁处理中
	return tp~=ep and Duel.GetCurrentChain()==0
end
-- 过滤函数：自己场上表侧表示的「弹丸」怪兽
function c7987191.filter(c,e)
	return c:IsFaceup() and c:IsSetCard(0x102) and c:IsType(TYPE_MONSTER)
end
-- 效果目标：设置无效特殊召唤以及破坏怪兽的操作信息
function c7987191.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return true end
	-- 设置无效特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DISABLE_SUMMON,eg,eg:GetCount(),0,0)
	-- 获取自己场上所有的「弹丸」怪兽
	local g=Duel.GetMatchingGroup(c7987191.filter,tp,LOCATION_MZONE,0,nil)
	g:AddCard(c)
	g:Merge(eg)
	-- 设置破坏特殊召唤的怪兽及自己场上1张卡的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,eg:GetCount()+1,0,0)
end
-- 效果处理：无效怪兽的特殊召唤并将其破坏，那之后选择自己场上此卡或1只「弹丸」怪兽破坏
function c7987191.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 使正在特殊召唤的怪兽特殊召唤无效
	Duel.NegateSummon(eg)
	-- 破坏那些特殊召唤被无效的怪兽
	Duel.Destroy(eg,REASON_EFFECT)
	-- 获取自己场上所有表侧表示的「弹丸」怪兽
	local g=Duel.GetMatchingGroup(c7987191.filter,tp,LOCATION_MZONE,0,nil)
	if c:IsRelateToEffect(e) then g:AddCard(c) end
	-- 提示玩家选择要破坏的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	local sg=g:Select(tp,1,1,nil)
	if sg:GetCount()>0 then
		-- 中断当前效果处理（使前后的效果处理不同时进行）
		Duel.BreakEffect()
		-- 显示被选择的卡片效果动画
		Duel.HintSelection(sg)
		-- 破坏自己场上选择的卡
		Duel.Destroy(sg,REASON_EFFECT)
	end
end
-- 过滤函数：墓地中可以加入手牌的「枪管」怪兽或「弹丸」怪兽
function c7987191.thfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x10f,0x102) and c:IsAbleToHand()
end
-- 效果目标：选择自己墓地1只「枪管」怪兽或「弹丸」怪兽作为对象
function c7987191.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c7987191.thfilter(chkc) end
	-- 检查自己墓地是否存在可加入手牌的「枪管」或「弹丸」怪兽
	if chk==0 then return Duel.IsExistingTarget(c7987191.thfilter,tp,LOCATION_GRAVE,0,1,nil)
		-- 并检查自己手牌或场上是否存在至少1张可以破坏的卡
		and Duel.IsExistingMatchingCard(nil,tp,LOCATION_ONFIELD+LOCATION_HAND,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择自己墓地1只「枪管」怪兽或「弹丸」怪兽作为效果的对象
	local g1=Duel.SelectTarget(tp,c7987191.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 获取自己手牌和场上的所有卡片
	local g=Duel.GetMatchingGroup(nil,tp,LOCATION_ONFIELD+LOCATION_HAND,0,nil)
	-- 设置将目标怪兽加入手牌的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g1,1,0,0)
	-- 设置破坏自己手牌或场上1张卡的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理：破坏自己手牌或场上的1张卡，那之后将墓地的目标怪兽加入手牌
function c7987191.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的对象怪兽
	local tc=Duel.GetFirstTarget()
	-- 提示玩家选择要破坏的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家从自己的手牌或场上选择1张要破坏的卡
	local g=Duel.SelectMatchingCard(tp,nil,tp,LOCATION_ONFIELD+LOCATION_HAND,0,1,1,nil)
	if #g==0 then return end
	-- 显示选中的卡片被破坏的动作提示
	Duel.HintSelection(g)
	-- 如果破坏成功，且目标怪兽仍与该效果相关
	if Duel.Destroy(g,REASON_EFFECT)~=0 and tc:IsRelateToEffect(e) then
		-- 将作为对象的怪兽加入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
