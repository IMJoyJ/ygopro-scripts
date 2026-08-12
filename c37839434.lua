--剣鬼の神域
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：可以从以下效果选择1个发动。
-- ●这张卡变成通常怪兽（水族·调整·水·1星·攻/守0）在怪兽区域特殊召唤（不当作陷阱卡使用）。那之后，可以进行1只同调怪兽的同调召唤。
-- ●对方把魔法·陷阱卡的效果发动时，若对方场上没有里侧表示卡存在则能发动。那个效果无效。
local s,id,o=GetID()
-- 初始化函数：为这张卡创建并注册发动效果e1，类型为魔陷发动（自由时点），效果分类含特殊召唤与效果无效，并设置同名卡1回合只能发动1张的次数限制
function s.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：可以从以下效果选择1个发动。●这张卡变成通常怪兽（水族·调整·水·1星·攻/守0）在怪兽区域特殊召唤（不当作陷阱卡使用）。那之后，可以进行1只同调怪兽的同调召唤。●对方把魔法·陷阱卡的效果发动时，若对方场上没有里侧表示卡存在则能发动。那个效果无效。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"发动"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 定义过滤函数：表侧表示的0x1e4系列怪兽（本脚本中未被实际调用）
function s.cfilter(c)
	return c:IsFaceupEx() and c:IsSetCard(0x1e4) and c:IsType(TYPE_MONSTER)
end
-- 效果目标处理：分别判断两个选项是否可选（能否把这张卡当作怪兽特殊召唤、能否无效对方刚发动的魔法·陷阱效果），让玩家从可选项中选择1个，记录所选选项并设置对应的操作信息
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=e:IsCostChecked()
		-- 自己怪兽区域有1个以上可用的空格
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 自己可以把这张卡当作水族·调整·水属性·1星·攻/守0的通常陷阱怪兽特殊召唤
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id,0x1e4,TYPES_NORMAL_TRAP_MONSTER+TYPE_TUNER,0,0,1,RACE_AQUA,ATTRIBUTE_WATER)
	-- 获取当前正在处理的连锁序号
	local ch=Duel.GetCurrentChain()
	local b2=false
	local og=Group.CreateGroup()
	local tsp=-1
	local tse=nil
	if e:GetHandler():IsStatus(STATUS_CHAINING) then ch=ch-1 end
	if ch>0 then
		-- 取得该连锁的发动玩家和发动的效果
		tsp,tse=Duel.GetChainInfo(ch,CHAININFO_TRIGGERING_PLAYER,CHAININFO_TRIGGERING_EFFECT)
		og:AddCard(tse:GetHandler())
		-- 判断选项2是否可选：该连锁由对方发动、对方场上没有里侧表示的卡存在、该效果为魔法·陷阱卡的效果且该连锁的效果可以被无效
		b2=tsp==1-tp and not Duel.IsExistingMatchingCard(Card.IsFacedown,tp,0,LOCATION_ONFIELD,1,nil) and tse:IsActiveType(TYPE_SPELL+TYPE_TRAP) and Duel.IsChainDisablable(ev)
	end
	if chk==0 then return b1 or b2 end
	local op=0
	if b1 or b2 then
		-- 让玩家从「当作怪兽特殊召唤」和「效果无效」两个可选项中选择1个发动
		op=aux.SelectFromOptions(tp,
			{b1,aux.Stringid(id,1),1},  --"当作怪兽特殊召唤"
			{b2,aux.Stringid(id,2),2})  --"效果无效"
	end
	e:SetLabel(op)
	if op==1 then
		if e:IsCostChecked() then
			e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		end
		-- 设置操作信息：将把这张卡当作怪兽特殊召唤1只
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	elseif op==2 then
		if e:IsCostChecked() then
			e:SetCategory(CATEGORY_DISABLE)
		end
		-- 设置操作信息：将使对方那张魔法·陷阱卡的发动的效果无效
		Duel.SetOperationInfo(0,CATEGORY_DISABLE,og,1,0,0)
	end
end
-- 效果处理：若选择选项1，把这张卡当作通常怪兽特殊召唤，之后可以选额外卡组1只同调怪兽进行同调召唤；若选择选项2，将对方发动的那个魔法·陷阱效果无效
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==1 then
		local c=e:GetHandler()
		-- 确认这张卡仍与连锁相关联且仍可当作陷阱怪兽特殊召唤
		if c:IsRelateToChain() and Duel.IsPlayerCanSpecialSummonMonster(tp,id,0x1e4,TYPES_NORMAL_TRAP_MONSTER+TYPE_TUNER,0,0,1,RACE_AQUA,ATTRIBUTE_WATER) then
			c:AddMonsterAttribute(TYPE_NORMAL+TYPE_TUNER)
			-- 把这张卡当作水族·调整·水属性·1星·攻/守0的通常怪兽（不当作陷阱卡使用）在自己怪兽区域表侧表示特殊召唤，并确认特殊召唤成功
			if Duel.SpecialSummon(c,0,tp,tp,true,false,POS_FACEUP)~=0 then
				-- 检索自己额外卡组中可以进行同调召唤的同调怪兽
				local g=Duel.GetMatchingGroup(Card.IsSynchroSummonable,tp,LOCATION_EXTRA,0,nil,nil)
				-- 若存在可以进行同调召唤的怪兽，询问玩家是否进行同调召唤
				if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then  --"是否同调召唤？"
					-- 中断当前效果处理，使之后的同调召唤与之前的处理视为不同时进行（造成错时点）
					Duel.BreakEffect()
					-- 向玩家发送选卡提示「请选择要特殊召唤的卡」
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
					local sg=g:Select(tp,1,1,nil)
					-- 以这张卡为调整，用场上的卡为素材，将选中的同调怪兽进行同调召唤
					Duel.SynchroSummon(tp,sg:GetFirst(),nil)
				end
			end
		end
	elseif e:GetLabel()==2 then
		-- 获取当前正在处理的连锁序号（用于定位要无效的上一个连锁）
		local ch=Duel.GetCurrentChain()
		-- 使上一个连锁的效果（对方发动的魔法·陷阱卡的效果）无效
		Duel.NegateEffect(ch-1)
	end
end
