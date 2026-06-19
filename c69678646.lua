--神星なる繋束
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：可以从以下效果选择1个发动。这个回合，自己不是超量怪兽不能从额外卡组特殊召唤。
-- ●选自己1张手卡丢弃，相同种族的怪兽不在自己场上存在的1只「星骑士」、「星圣」怪兽从卡组特殊召唤。
-- ●以最多有自己场上的「星骑士」、「星圣」怪兽数量的对方场上的表侧表示怪兽为对象才能发动。那些怪兽的效果直到回合结束时无效。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数
function s.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：可以从以下效果选择1个发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DISABLE+CATEGORY_HANDES_SELF)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数：检查场上怪兽是否与目标怪兽种族相同
function s.racefilter(c,sc)
	-- 检查场上表侧表示的怪兽与目标怪兽是否种族相同
	return c:IsFaceup() and aux.SameValueCheck(Group.FromCards(c,sc),Card.GetRace)
end
-- 过滤函数：从卡组特殊召唤的「星骑士」或「星圣」怪兽，且其种族不在自己场上存在
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x9c,0x53) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查自己场上是否存在与该卡相同种族的怪兽
		and not Duel.IsExistingMatchingCard(s.racefilter,tp,LOCATION_MZONE,0,1,nil,c)
end
-- 过滤函数：自己场上表侧表示的「星骑士」或「星圣」怪兽
function s.cfilter(c)
	return c:IsSetCard(0x9c,0x53) and c:IsFaceup()
end
-- 效果发动时的目标选择与合法性检查函数
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 检查是否为合法的对方场上表侧表示且未被无效的效果怪兽对象
	if chkc then return chkc:IsControler(1-tp) and aux.NegateMonsterFilter(chkc) and chkc:IsLocation(LOCATION_MZONE) end
	-- 获取手牌中可以因效果丢弃的卡片组
	local sg=Duel.GetMatchingGroup(Card.IsDiscardable,tp,LOCATION_HAND,0,e:GetHandler(),REASON_EFFECT+REASON_DISCARD)
	-- 检查是否满足分支1的发动条件：手牌有可丢弃的卡，且卡组有可特殊召唤的怪兽
	local b1=sg:GetCount()>0 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp)
		-- 检查自己场上是否有空余的怪兽区域
		and Duel.GetMZoneCount(tp)>0
	-- 计算自己场上表侧表示的「星骑士」、「星圣」怪兽数量
	local ct=Duel.GetMatchingGroupCount(s.cfilter,tp,LOCATION_MZONE,0,nil)
	-- 检查是否满足分支2的发动条件：自己场上有「星骑士」或「星圣」怪兽，且对方场上有可无效的表侧表示怪兽
	local b2=ct>0 and Duel.IsExistingTarget(aux.NegateMonsterFilter,tp,0,LOCATION_MZONE,1,nil)
	if chk==0 then return b1 or b2 end
	local op=0
	if b1 or b2 then
		-- 让玩家选择发动其中一个效果分支
		op=aux.SelectFromOptions(tp,
			{b1,aux.Stringid(id,1),1},  --"特殊召唤"
			{b2,aux.Stringid(id,2),2})  --"效果无效"
	end
	e:SetLabel(op)
	if op==1 then
		if e:IsCostChecked() then
			e:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_HANDES_SELF)
			e:SetProperty(0)
		end
		-- 设置连锁信息：从卡组特殊召唤1只怪兽
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
		Duel.SetOperationInfo(0,CATEGORY_HANDES_SELF,nil,0,tp,1)
	elseif op==2 then
		if e:IsCostChecked() then
			e:SetCategory(CATEGORY_DISABLE)
			e:SetProperty(EFFECT_FLAG_CARD_TARGET)
		end
		-- 提示玩家选择要无效效果的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
		-- 选择最多有自己场上「星骑士」、「星圣」怪兽数量的对方场上的表侧表示怪兽作为对象
		local g=Duel.SelectTarget(tp,aux.NegateMonsterFilter,tp,0,LOCATION_MZONE,1,ct,nil)
		-- 设置连锁信息：使选定对象的效果无效
		Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,g:GetCount(),0,0)
	end
end
-- 效果处理的执行函数
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if e:GetLabel()==1 then
		-- 获取手牌中可以因效果丢弃的卡片组
		local sg=Duel.GetMatchingGroup(Card.IsDiscardable,tp,LOCATION_HAND,0,nil,REASON_EFFECT+REASON_DISCARD)
		if sg:GetCount()>0 then
			-- 提示玩家选择要丢弃的手牌
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
			local dg=sg:Select(tp,1,1,nil)
			-- 将选中的手牌送去墓地，并检查是否成功送去墓地
			if Duel.SendtoGrave(dg,REASON_EFFECT+REASON_DISCARD)~=0
				-- 检查自己场上是否有空余的怪兽区域
				and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
				-- 提示玩家选择要特殊召唤的怪兽
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
				-- 从卡组选择1只满足条件的「星骑士」或「星圣」怪兽
				local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
				if g:GetCount()>0 then
					-- 将选中的怪兽以表侧表示特殊召唤
					Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
				end
			end
		end
	elseif e:GetLabel()==2 then
		-- 获取在连锁处理时仍与该效果关联的对象卡片
		local tg=Duel.GetTargetsRelateToChain()
		-- 遍历所有关联的对象卡片
		for tc in aux.Next(tg) do
			if tc:IsFaceup() and tc:IsType(TYPE_MONSTER) and tc:IsRelateToChain() and tc:IsCanBeDisabledByEffect(e,false) then
				-- 无效与该卡片相关的连锁
				Duel.NegateRelatedChain(tc,RESET_TURN_SET)
				-- 那些怪兽的效果直到回合结束时无效。
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_DISABLE)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
				tc:RegisterEffect(e1)
				-- 那些怪兽的效果直到回合结束时无效。
				local e2=Effect.CreateEffect(c)
				e2:SetType(EFFECT_TYPE_SINGLE)
				e2:SetCode(EFFECT_DISABLE_EFFECT)
				e2:SetValue(RESET_TURN_SET)
				e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
				tc:RegisterEffect(e2)
			end
		end
	end
	-- 这个回合，自己不是超量怪兽不能从额外卡组特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetTargetRange(1,0)
	e3:SetReset(RESET_PHASE+PHASE_END)
	e3:SetTarget(s.splimit)
	-- 注册该回合内限制从额外卡组特殊召唤非超量怪兽的玩家效果
	Duel.RegisterEffect(e3,tp)
end
-- 限制特殊召唤的过滤函数：限制非超量怪兽从额外卡组特殊召唤
function s.splimit(e,c)
	return not c:IsType(TYPE_XYZ) and c:IsLocation(LOCATION_EXTRA)
end
