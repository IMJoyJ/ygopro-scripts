--ディスカバード・アタック
-- 效果：
-- 祭掉自己场上1只名称中含有「恶魔」字样的怪兽。本回合，自己场上的1只「灭绝国王恶魔」可以对对方进行直接攻击。
function c69313735.initial_effect(c)
	-- 祭掉自己场上1只名称中含有「恶魔」字样的怪兽。本回合，自己场上的1只「灭绝国王恶魔」可以对对方进行直接攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c69313735.condition)
	e1:SetCost(c69313735.cost)
	e1:SetTarget(c69313735.target)
	e1:SetOperation(c69313735.activate)
	c:RegisterEffect(e1)
end
-- 发动条件判定：检查当前回合玩家是否能进入战斗阶段
function c69313735.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前回合玩家是否能进入战斗阶段
	return Duel.IsAbleToEnterBP()
end
-- 发动代价处理：设置标记以指示需要进行解放代价的检测与处理
function c69313735.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	return true
end
-- 过滤函数：自己场上可解放的「恶魔」怪兽，且场上存在除该卡以外的「灭绝国王恶魔」作为效果对象
function c69313735.rfilter(c,tp)
	-- 检查卡片是否为「恶魔」怪兽，且场上是否存在除该卡以外的「灭绝国王恶魔」作为效果对象
	return c:IsSetCard(0x45) and Duel.IsExistingTarget(c69313735.filter,tp,LOCATION_MZONE,0,1,c)
end
-- 过滤函数：自己场上表侧表示的「灭绝国王恶魔」
function c69313735.filter(c)
	return c:IsFaceup() and c:IsCode(35975813)
end
-- 效果目标选择：处理解放代价并选择自己场上1只表侧表示的「灭绝国王恶魔」作为效果对象
function c69313735.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c69313735.filter(chkc) end
	if chk==0 then
		-- 若非发动时（如被其他卡片效果复制时），检查场上是否存在可选择的「灭绝国王恶魔」
		if e:GetLabel()==0 then return Duel.IsExistingTarget(c69313735.filter,tp,LOCATION_MZONE,0,1,nil) end
		e:SetLabel(0)
		-- 检查自己场上是否存在可作为解放代价的「恶魔」怪兽
		return Duel.CheckReleaseGroup(tp,c69313735.rfilter,1,nil,tp)
	end
	if e:GetLabel()~=0 then
		e:SetLabel(0)
		-- 选择自己场上1只「恶魔」怪兽作为解放代价
		local rg=Duel.SelectReleaseGroup(tp,c69313735.rfilter,1,1,nil,tp)
		-- 解放选择的怪兽以支付发动代价
		Duel.Release(rg,REASON_COST)
	end
	-- 提示玩家选择表侧表示的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1只表侧表示的「灭绝国王恶魔」作为效果对象
	Duel.SelectTarget(tp,c69313735.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果运行处理：使选择的「灭绝国王恶魔」在本回合可以直接攻击
function c69313735.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果发动的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 本回合，自己场上的1只「灭绝国王恶魔」可以对对方进行直接攻击。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DIRECT_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
