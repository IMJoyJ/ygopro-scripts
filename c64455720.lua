--色鬼の蟲毒
local s,id,o=GetID()
-- 初始化卡片效果：注册二选一发动效果（自身作为陷阱怪兽特召并可同调召唤，或特召墓地「色鬼」怪兽）
function s.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：可以从以下效果选择1个发动。●这张卡变为通常怪兽（昆虫族·调整·暗·1星·攻/守0）在怪兽区域特殊召唤（不当作陷阱卡使用）。那之后，可以进行1只同调怪兽的同调召唤。●以自己墓地1只「色鬼」怪兽为对象才能发动。那只怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 墓地特召过滤条件：「色鬼」怪兽且可特殊召唤
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x1e4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 发动准备：处理取对象重检、检查各分支发动条件，让玩家选择分支并设置对应操作信息
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.spfilter(chkc,e,tp) end
	local b1=e:IsCostChecked()
		-- 检查怪兽区域是否有空位
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家是否可以将此卡作为陷阱怪兽（昆虫族·调整·暗·1星·攻/守0）特殊召唤
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id,0x1e4,TYPES_NORMAL_TRAP_MONSTER+TYPE_TUNER,0,0,1,RACE_INSECT,ATTRIBUTE_DARK)
	-- 检查怪兽区域是否有空位
	local b2=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查墓地是否存在可特殊召唤的「色鬼」怪兽
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
	if chk==0 then return b1 or b2 end
	local op=0
	if b1 or b2 then
		-- 提示玩家选择要发动的效果分支
		op=aux.SelectFromOptions(tp,
			{b1,aux.Stringid(id,1),1},
			{b2,aux.Stringid(id,2),2})
	end
	e:SetLabel(op)
	if op==1 then
		if e:IsCostChecked() then
			e:SetProperty(0)
		end
		-- 设置连锁操作信息：从魔陷区特殊召唤自身
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	elseif op==2 then
		if e:IsCostChecked() then
			e:SetProperty(EFFECT_FLAG_CARD_TARGET)
		end
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 选择墓地1只「色鬼」怪兽作为对象
		local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
		-- 设置连锁操作信息：特殊召唤对象怪兽1只
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
	end
end
-- 效果处理：根据选择的分支，执行自身特召及同调召唤，或特召墓地的目标怪兽
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==1 then
		local c=e:GetHandler()
		-- 检查自身是否仍关联连锁且可作为陷阱怪兽特殊召唤
		if c:IsRelateToChain() and Duel.IsPlayerCanSpecialSummonMonster(tp,id,0x1e4,TYPES_NORMAL_TRAP_MONSTER+TYPE_TUNER,0,0,1,RACE_INSECT,ATTRIBUTE_DARK) then
			c:AddMonsterAttribute(TYPE_NORMAL+TYPE_TUNER)
			-- 将自身以表侧表示特殊召唤，若成功特召则继续后续处理
			if Duel.SpecialSummon(c,0,tp,tp,true,false,POS_FACEUP)~=0 then
				-- 获取额外卡组中当前可进行同调召唤的怪兽
				local g=Duel.GetMatchingGroup(Card.IsSynchroSummonable,tp,LOCATION_EXTRA,0,nil,nil)
				-- 确认存在可同调召唤的怪兽并询问玩家是否进行同调召唤
				if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
					-- 连接效果块（分隔自身特殊召唤与同调召唤处理）
					Duel.BreakEffect()
					-- 提示玩家选择要进行同调召唤的怪兽
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
					local sg=g:Select(tp,1,1,nil)
					-- 对选中的怪兽进行同调召唤
					Duel.SynchroSummon(tp,sg:GetFirst(),nil)
				end
			end
		end
	elseif e:GetLabel()==2 then
		-- 获取连锁中的对象怪兽
		local tc=Duel.GetFirstTarget()
		-- 检查对象怪兽是否仍关联连锁且不受王家长眠之谷影响
		if tc:IsRelateToChain() and aux.NecroValleyFilter()(tc) then
			-- 将对象怪兽表侧表示特殊召唤
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
