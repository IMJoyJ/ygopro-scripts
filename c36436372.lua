--ギミック・パペット－リトル・ソルジャーズ
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡召唤·特殊召唤的场合，把和这张卡等级不同的1只「机关傀儡」怪兽从卡组送去墓地才能发动。这张卡的等级变成和送去墓地的怪兽相同。
-- ②：把墓地的这张卡除外，以自己场上最多2只「机关傀儡」怪兽为对象才能发动。那些怪兽的等级直到回合结束时上升4星。
local s,id,o=GetID()
-- 注册效果：①效果，通常召唤成功时发动，需要支付代价并改变自身等级
function s.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤的场合，把和这张卡等级不同的1只「机关傀儡」怪兽从卡组送去墓地才能发动。这张卡的等级变成和送去墓地的怪兽相同。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"送墓等级变化"
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.lvcost)
	e1:SetOperation(s.lvop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：把墓地的这张卡除外，以自己场上最多2只「机关傀儡」怪兽为对象才能发动。那些怪兽的等级直到回合结束时上升4星。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"等级上升"
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	-- 支付将自身除外的代价
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(s.uptg)
	e3:SetOperation(s.upop)
	c:RegisterEffect(e3)
end
-- 过滤函数：用于筛选卡组中满足条件的「机关傀儡」怪兽（等级不同且可送入墓地）
function s.costfilter(c,lv)
	return not c:IsLevel(lv) and c:IsLevelAbove(1) and c:IsSetCard(0x1083) and c:IsAbleToGraveAsCost()
end
-- ①效果的发动代价处理：选择并送入墓地一张符合条件的怪兽
function s.lvcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local lv=e:GetHandler():GetLevel()
	-- 检查是否满足①效果发动的条件：卡组中是否存在符合条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_DECK,0,1,nil,lv) end
	-- 提示玩家选择要送入墓地的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从卡组中选择一张符合条件的怪兽送入墓地
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_DECK,0,1,1,nil,lv)
	-- 执行将选中的怪兽送入墓地的操作
	Duel.SendtoGrave(g,REASON_COST)
	e:SetLabel(g:GetFirst():GetLevel())
end
-- ①效果的发动处理：改变自身等级为送入墓地怪兽的等级
function s.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local lv=e:GetLabel()
	if c:IsRelateToEffect(e) and c:IsFaceup() and not c:IsLevel(lv) then
		-- 将自身等级修改为指定值的效果
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(lv)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end
-- 过滤函数：用于筛选场上满足条件的「机关傀儡」怪兽（表侧表示且等级大于等于1）
function s.upfilter(c)
	return c:IsFaceup() and c:IsLevelAbove(1) and c:IsSetCard(0x1083)
end
-- ②效果的目标选择处理：选择场上1~2只符合条件的怪兽作为对象
function s.uptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and s.upfilter(chkc) and chkc~=e:GetHandler() end
	-- 检查是否满足②效果发动的条件：场上是否存在符合条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(s.upfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择要提升等级的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择场上1~2只符合条件的怪兽作为对象
	local g=Duel.SelectTarget(tp,s.upfilter,tp,LOCATION_MZONE,0,1,2,nil)
end
-- ②效果的发动处理：提升目标怪兽等级4星直到回合结束
function s.upop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取与当前连锁相关的对象怪兽组
	local sg=Duel.GetTargetsRelateToChain()
	if #sg==0 then return end
	-- 遍历对象怪兽组，为每只怪兽添加等级提升效果
	for tc in aux.Next(sg) do
		if tc:IsFaceup() and tc:IsType(TYPE_MONSTER) then
			-- 提升目标怪兽等级4星的效果
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_LEVEL)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			e1:SetValue(4)
			tc:RegisterEffect(e1)
		end
	end
end
