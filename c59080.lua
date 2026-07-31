--聖魔 裁きの雷
local s,id,o=GetID()
-- 初始化卡片效果：注册去除指示物或送墓魔导书卡发动选一的效果（手卡/额外/墓地特召魔法师族怪兽，或除外场上1张卡）
function s.initial_effect(c)
	-- 去除自己场上2个魔力指示物，或者把对方以外场上1张表侧表示的「魔导书」卡送去墓地才能发动。选以下1个效果发动（同名卡1回合各只能选择1次）。
●从自己的手卡·额外卡组·墓地选1只魔法师族怪兽特殊召唤。
●选场上1张卡除外。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON|CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.mentioned_counter={
	[0x1]=true,
}
-- Cost可行性辅助判断：检查场上是否有除Cost外的卡可除外，或手卡/额外/墓地是否有可特召的魔法师族怪兽
function s.costcheck(c,ec,e,tp)
	-- 判断场上除Cost卡和发动卡以外是否存在可除外的卡
	return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,Group.FromCards(c,ec))
	-- 判断手卡·额外卡组·墓地是否存在当前场地上可特殊召唤的魔法师族怪兽
	or Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_EXTRA+LOCATION_GRAVE,0,1,nil,e,tp,c)
end
-- Cost过滤条件：场上表侧表示的「魔导书」卡，且可作为Cost送去墓地并满足发动后有有效效果处理
function s.tgfilter(c,ec,e,tp)
	return c:IsFaceup() and c:IsSetCard(0x150) and c:IsAbleToGraveAsCost() and s.costcheck(c,ec,e,tp)
end
-- 卡片发动Cost：选择去除2个魔力指示物，或把场上1张表侧表示「魔导书」卡送去墓地
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断选项1（去除2个魔力指示物）是否满足Cost条件且有可处理效果
	local b1=Duel.IsCanRemoveCounter(tp,1,0,0x1,2,REASON_COST) and s.costcheck(nil,e:GetHandler(),e,tp)
	-- 判断选项2（送墓1张场上「魔导书」卡）是否满足Cost条件且有可处理效果
	local b2=Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_ONFIELD,0,1,e:GetHandler(),e:GetHandler(),e,tp)
	if chk==0 then return b1 or b2 end
	local cost=0
	if b1 or b2 then
		-- 由玩家选择 Cost 支付方式（去除指示物或送墓魔导书卡）
		cost=aux.SelectFromOptions(tp,
			{b1,aux.Stringid(id,1),1},
			{b2,aux.Stringid(id,2),2})
	end
	if cost==1 then
		-- 扣除2个魔力指示物作为Cost
		Duel.RemoveCounter(tp,1,0,0x1,2,REASON_COST)
	elseif cost==2 then
		-- 提示玩家选择要送去墓地的「魔导书」卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		-- 选择场上1张表侧表示的「魔导书」卡
		local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_ONFIELD,0,1,1,e:GetHandler(),e:GetHandler(),e,tp)
		-- 将选中的「魔导书」卡作为Cost送去墓地
		Duel.SendtoGrave(g,REASON_COST)
	end
end
-- 特召过滤条件：表侧表示的魔法师族怪兽，可特殊召唤且符合相应区域的空位限制
function s.spfilter(c,e,tp,rc)
	return c:IsFaceupEx() and c:IsRace(RACE_SPELLCASTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 非额外卡组怪兽特召条件：主怪兽区域有空位
		and (not c:IsLocation(LOCATION_EXTRA) and Duel.GetMZoneCount(tp,rc)>0
			-- 额外卡组怪兽特召条件：额外怪兽区域或所连接区有空位
			or c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(tp,tp,rc,c)>0)
end
-- 效果发动准备：选择效果分支（1:特殊召唤魔法师族怪兽 / 2:除外场上的卡），并注册同名效果本回合发动标记
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 辅助判断：若通过送墓魔导书支付Cost，计算场上空位对特召条件的影响
	local b0=Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_ONFIELD,0,1,e:GetHandler(),e:GetHandler(),e,tp) and e:IsCostChecked()
	-- 判断分支1（特殊召唤魔法师族怪兽）是否可选择且本回合尚未发动过
	local b1=(Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_EXTRA+LOCATION_GRAVE,0,1,nil,e,tp,nil) or b0)
		-- 检查本回合分支1（特召效果）是否未发动过
		and (Duel.GetFlagEffect(tp,id)==0 or not e:IsCostChecked())
	-- 判断分支2（除外场上的卡）是否可选择且本回合尚未发动过
	local b2=Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler())
		-- 检查本回合分支2（除外效果）是否未发动过
		and (Duel.GetFlagEffect(tp,id+o)==0 or not e:IsCostChecked())
	if chk==0 then return b1 or b2 end
	local op=0
	if b1 or b2 then
		-- 由玩家选择要发动的效果分支
		op=aux.SelectFromOptions(tp,
			{b1,aux.Stringid(id,3),1},
			{b2,aux.Stringid(id,4),2})
	end
	e:SetLabel(op)
	if op==1 then
		if e:IsCostChecked() then
			e:SetCategory(CATEGORY_SPECIAL_SUMMON)
			-- 注册分支1本回合已发动的Flag标记
			Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
		end
		-- 设置连锁操作信息：从手卡·额外卡组·墓地特殊召唤1只怪兽
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_EXTRA+LOCATION_GRAVE)
	elseif op==2 then
		if e:IsCostChecked() then
			-- 注册分支2本回合已发动的Flag标记
			Duel.RegisterFlagEffect(tp,id+o,RESET_PHASE+PHASE_END,0,1)
			e:SetCategory(CATEGORY_REMOVE)
		end
		-- 设置连锁操作信息：除外场上1张卡
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_ONFIELD)
	end
end
-- 效果处理：根据选择的分支执行特召魔法师族怪兽或除外场上卡片
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==1 then
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从手卡·额外卡组·墓地选择1只满足条件的魔法师族怪兽（受王谷影响）
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND+LOCATION_EXTRA+LOCATION_GRAVE,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选中的怪兽表侧表示特殊召唤
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	elseif e:GetLabel()==2 then
		-- 提示玩家选择要除外的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		-- 从场上选择1张可除外的卡（排除自身）
		local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,aux.ExceptThisCard(e))
		if g:GetCount()>0 then
			-- 高亮显示选中的目标卡片
			Duel.HintSelection(g)
			-- 将选中的卡表侧表示除外
			Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
		end
	end
end
