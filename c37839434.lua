--剣鬼の神域
local s,id,o=GetID()
-- 创建并注册一张发动时可以进行特殊召唤或无效连锁效果的魔法卡
function s.initial_effect(c)
	-- 这张卡发动时，可以选择以下效果之一进行处理：①特殊召唤自己作为调整怪兽；②无效对方场上一个魔法或陷阱的效果
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于判断场上是否有已翻开的「剑鬼」卡组怪兽
function s.cfilter(c)
	return c:IsFaceupEx() and c:IsSetCard(0x1e4) and c:IsType(TYPE_MONSTER)
end
-- 判断是否满足发动条件：1.当前效果未支付费用；2.玩家场上存在空位；3.可以特殊召唤指定参数的怪兽
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=e:IsCostChecked()
		-- 检查玩家场上是否存在可用的怪兽区域
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家是否可以特殊召唤指定参数的怪兽到场上
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id,0x1e4,TYPES_NORMAL_TRAP_MONSTER+TYPE_TUNER,0,0,1,RACE_AQUA,ATTRIBUTE_WATER)
	-- 获取当前正在处理的连锁编号
	local ch=Duel.GetCurrentChain()
	local b2=false
	local og=Group.CreateGroup()
	local tsp=-1
	local tse=nil
	if e:GetHandler():IsStatus(STATUS_CHAINING) then ch=ch-1 end
	if ch>0 then
		-- 获取当前连锁的触发玩家和触发效果信息
		tsp,tse=Duel.GetChainInfo(ch,CHAININFO_TRIGGERING_PLAYER,CHAININFO_TRIGGERING_EFFECT)
		og:AddCard(tse:GetHandler())
		-- 判断是否满足无效连锁效果的条件：1.触发玩家为对方；2.对方场上有翻开的卡；3.触发效果为魔法或陷阱类型；4.该连锁可以被无效
		b2=tsp==1-tp and not Duel.IsExistingMatchingCard(Card.IsFacedown,tp,0,LOCATION_ONFIELD,1,nil) and tse:IsActiveType(TYPE_SPELL+TYPE_TRAP) and Duel.IsChainDisablable(ev)
	end
	if chk==0 then return b1 or b2 end
	local op=0
	if b1 or b2 then
		-- 让玩家选择发动选项，选项包括特殊召唤或无效效果
		op=aux.SelectFromOptions(tp,
			{b1,aux.Stringid(id,1),1},
			{b2,aux.Stringid(id,2),2})
	end
	e:SetLabel(op)
	if op==1 then
		if e:IsCostChecked() then
			e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		end
		-- 设置操作信息为特殊召唤类别，用于后续处理
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	elseif op==2 then
		if e:IsCostChecked() then
			e:SetCategory(CATEGORY_DISABLE)
		end
		-- 设置操作信息为无效效果类别，用于后续处理
		Duel.SetOperationInfo(0,CATEGORY_DISABLE,og,1,0,0)
	end
end
-- 处理发动效果：若选择特殊召唤则将自己特殊召唤并可进行一次同调召唤；若选择无效效果则无效上一个连锁的效果
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==1 then
		local c=e:GetHandler()
		-- 检查当前卡是否与连锁相关联，并判断玩家是否可以特殊召唤指定参数的怪兽
		if c:IsRelateToChain() and Duel.IsPlayerCanSpecialSummonMonster(tp,id,0x1e4,TYPES_NORMAL_TRAP_MONSTER+TYPE_TUNER,0,0,1,RACE_AQUA,ATTRIBUTE_WATER) then
			c:AddMonsterAttribute(TYPE_NORMAL+TYPE_TUNER)
			-- 将当前卡以特殊召唤方式送入场上，不考虑召唤条件和限制
			if Duel.SpecialSummon(c,0,tp,tp,true,false,POS_FACEUP)~=0 then
				-- 获取玩家额外卡组中所有可同调召唤的怪兽组
				local g=Duel.GetMatchingGroup(Card.IsSynchroSummonable,tp,LOCATION_EXTRA,0,nil,nil)
				-- 判断是否有可同调召唤的怪兽且玩家选择进行同调召唤
				if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
					-- 中断当前连锁处理，使之后的效果视为错时处理
					Duel.BreakEffect()
					-- 提示玩家选择要特殊召唤的卡
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
					local sg=g:Select(tp,1,1,nil)
					-- 使用所选的卡进行一次同调召唤
					Duel.SynchroSummon(tp,sg:GetFirst(),nil)
				end
			end
		end
	elseif e:GetLabel()==2 then
		-- 获取当前正在处理的连锁编号
		local ch=Duel.GetCurrentChain()
		-- 使上一个连锁的效果无效
		Duel.NegateEffect(ch-1)
	end
end
