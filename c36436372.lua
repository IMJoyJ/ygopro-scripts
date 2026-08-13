--ギミック・パペット－リトル・ソルジャーズ
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡召唤·特殊召唤的场合，把和这张卡等级不同的1只「机关傀儡」怪兽从卡组送去墓地才能发动。这张卡的等级变成和送去墓地的怪兽相同。
-- ②：把墓地的这张卡除外，以自己场上最多2只「机关傀儡」怪兽为对象才能发动。那些怪兽的等级直到回合结束时上升4星。
local s,id,o=GetID()
-- 创建并注册这张卡的全部效果：①效果（召唤成功时触发的送墓并变化等级，以及特殊召唤成功时的同名克隆效果）和②效果（墓地中除外自身起动，使场上机关傀儡怪兽等级上升）。
function s.initial_effect(c)
	-- 对应①中‘这张卡召唤的场合，把和这张卡等级不同的1只「机关傀儡」怪兽从卡组送去墓地才能发动。这张卡的等级变成和送去墓地的怪兽相同。’（召唤场合部分，特殊召唤部分由e2处理）。
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
	-- 对应②‘把墓地的这张卡除外，以自己场上最多2只「机关傀儡」怪兽为对象才能发动。那些怪兽的等级直到回合结束时上升4星。’
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"等级上升"
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	-- 设置②效果的发动代价为把墓地的这张卡除外（aux.bfgcost是除外自身作为cost的简写）。
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(s.uptg)
	e3:SetOperation(s.upop)
	c:RegisterEffect(e3)
end
-- 定义costfilter：筛选可作为代价从卡组送去墓地的‘机关傀儡’怪兽，要求与这张卡等级不同、等级1以上、卡名属于‘机关傀儡’字段且可以送去墓地。
function s.costfilter(c,lv)
	return not c:IsLevel(lv) and c:IsLevelAbove(1) and c:IsSetCard(0x1083) and c:IsAbleToGraveAsCost()
end
-- ①效果的代价处理：检查卡组中是否有符合筛选条件的‘机关傀儡’怪兽，从中选择1张送入墓地，并将其等级记录到效果标签中供后续变化等级使用。
function s.lvcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local lv=e:GetHandler():GetLevel()
	-- 发动合法性检查：确认卡组中是否存在至少1张满足costfilter条件的‘机关傀儡’怪兽可供作为代价送墓。
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_DECK,0,1,nil,lv) end
	-- 向玩家显示‘请选择要送去墓地的卡’的选择提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从卡组中选择1张满足costfilter条件的‘机关傀儡’怪兽作为代价。
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_DECK,0,1,1,nil,lv)
	-- 将选择的怪兽以代价方式从卡组送去墓地。
	Duel.SendtoGrave(g,REASON_COST)
	e:SetLabel(g:GetFirst():GetLevel())
end
-- ①效果处理：若这张卡仍与效果关联且表侧表示，并且当前等级与送墓怪兽等级不同，则给它设置一个把等级变成送墓怪兽等级的效果。
function s.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local lv=e:GetLabel()
	if c:IsRelateToEffect(e) and c:IsFaceup() and not c:IsLevel(lv) then
		-- 对应①中‘这张卡的等级变成和送去墓地的怪兽相同。’——通过EFFECT_CHANGE_LEVEL把这张卡的等级改为记录下来的送墓怪兽的等级。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(lv)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end
-- 定义upfilter：筛选自己场上表侧表示、等级1以上、卡名属于‘机关傀儡’字段的怪兽。
function s.upfilter(c)
	return c:IsFaceup() and c:IsLevelAbove(1) and c:IsSetCard(0x1083)
end
-- ②效果的取对象处理：选择自己场上1～2只满足upfilter条件的表侧表示‘机关傀儡’怪兽作为对象（此效果在墓地发动，自身不在场上，但chkc中仍排除效果发动者自身）。
function s.uptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and s.upfilter(chkc) and chkc~=e:GetHandler() end
	-- 取对象合法性检查：确认自己场上存在至少1只满足upfilter条件的表侧表示‘机关傀儡’怪兽可以作为对象。
	if chk==0 then return Duel.IsExistingTarget(s.upfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向玩家显示‘请选择表侧表示的卡’的选择提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1～2只满足upfilter条件的‘机关傀儡’怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,s.upfilter,tp,LOCATION_MZONE,0,1,2,nil)
end
-- ②效果处理：对当前连锁中所有关联的对象怪兽，各赋予等级上升4星直到结束阶段的效果。
function s.upop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中与效果关联的对象卡组（发动时通过Duel.SelectTarget选定的目标，若已离场则自动解除关联）。
	local sg=Duel.GetTargetsRelateToChain()
	if #sg==0 then return end
	-- 使用迭代器遍历对象卡组中的每一张卡。
	for tc in aux.Next(sg) do
		if tc:IsFaceup() and tc:IsType(TYPE_MONSTER) then
			-- 对应②中‘那些怪兽的等级直到回合结束时上升4星。’——通过EFFECT_UPDATE_LEVEL使对象怪兽的等级上升4，持续到结束阶段。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_LEVEL)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			e1:SetValue(4)
			tc:RegisterEffect(e1)
		end
	end
end
