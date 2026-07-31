--依鬼の呪咆
local s,id,o=GetID()
-- 初始化卡片效果：注册卡片发动（二选一：特召自身为调整后同调召唤 / 破坏对方怪兽）效果
function s.initial_effect(c)
	-- ①：可以从以下效果选择1个发动。
●这张卡发动后变成通常怪兽（魔法师族·调整·暗·1星·攻/守0）在怪兽区域特殊召唤（不当作陷阱卡使用）。那之后，可以把1只怪兽同调召唤。
●选自己场上（表侧表示）·墓地1只「依鬼」怪兽。以对方场上1只怪兽为对象才能发动。那只怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 破坏分支条件过滤：自己场上表侧表示或墓地的「依鬼」怪兽
function s.cfilter(c)
	return c:IsFaceupEx() and c:IsSetCard(0x1e4) and c:IsType(TYPE_MONSTER)
end
-- 效果发动准备：检查两个分支条件并由玩家选择发动的分支
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) end
	local b1=e:IsCostChecked()
		-- 分支1条件检查：主要怪兽区域有空位
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 分支1条件检查：自身能够作为陷阱怪兽特殊召唤
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id,0x1e4,TYPES_NORMAL_TRAP_MONSTER+TYPE_TUNER,0,0,1,RACE_SPELLCASTER,ATTRIBUTE_DARK)
	-- 分支2条件检查：自己场上或墓地存在表侧表示的「依鬼」怪兽
	local b2=Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,nil)
		-- 分支2条件检查：对方场上存在可作为对象的怪兽
		and Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_MZONE,1,nil)
	if chk==0 then return b1 or b2 end
	local op=0
	if b1 or b2 then
		-- 提示玩家从满足条件的分支中选择1个发动
		op=aux.SelectFromOptions(tp,
			{b1,aux.Stringid(id,1),1},
			{b2,aux.Stringid(id,2),2})
	end
	e:SetLabel(op)
	if op==1 then
		if e:IsCostChecked() then
			e:SetCategory(CATEGORY_SPECIAL_SUMMON)
			e:SetProperty(0)
		end
		-- 设置连锁操作信息：特殊召唤自身1张
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	elseif op==2 then
		if e:IsCostChecked() then
			e:SetCategory(CATEGORY_DESTROY)
			e:SetProperty(EFFECT_FLAG_CARD_TARGET)
		end
		-- 提示玩家选择要破坏的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		-- 从对方场上选择1只怪兽作为破坏对象
		local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_MZONE,1,1,nil)
		-- 设置连锁操作信息：破坏选中的1只怪兽
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	end
end
-- 卡片发动处理：根据选择的分支执行特召并同调召唤或破坏对方怪兽
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==1 then
		local c=e:GetHandler()
		-- 检查此卡是否关联连锁且满足陷阱怪兽特召条件
		if c:IsRelateToChain() and Duel.IsPlayerCanSpecialSummonMonster(tp,id,0x1e4,TYPES_NORMAL_TRAP_MONSTER+TYPE_TUNER,0,0,1,RACE_SPELLCASTER,ATTRIBUTE_DARK) then
			c:AddMonsterAttribute(TYPE_NORMAL+TYPE_TUNER)
			-- 将此卡表侧表示特殊召唤，成功后继续处理
			if Duel.SpecialSummon(c,0,tp,tp,true,false,POS_FACEUP)~=0 then
				-- 获取额外卡组中当前可以同调召唤的怪兽
				local g=Duel.GetMatchingGroup(Card.IsSynchroSummonable,tp,LOCATION_EXTRA,0,nil,nil)
				-- 若存在可同调召唤的怪兽，询问玩家是否进行同调召唤
				if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
					-- 中断效果处理（特召自身与同调召唤为非同时处理）
					Duel.BreakEffect()
					-- 提示玩家选择要特殊召唤的卡
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
					local sg=g:Select(tp,1,1,nil)
					-- 将选中的怪兽进行同调召唤
					Duel.SynchroSummon(tp,sg:GetFirst(),nil)
				end
			end
		end
	elseif e:GetLabel()==2 then
		-- 获取连锁选中的对方目标怪兽
		local tc=Duel.GetFirstTarget()
		if tc:IsRelateToChain() and tc:IsType(TYPE_MONSTER) then
			-- 将目标怪兽用卡片效果破坏
			Duel.Destroy(tc,REASON_EFFECT)
		end
	end
end
