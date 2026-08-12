--トポロジック・ブラスター・ドラゴン
-- 效果：
-- 效果怪兽2只以上
-- 自己不能在作为这张卡所连接区的额外怪兽区域让怪兽出现。
-- ①：这张卡在额外怪兽区域存在的状态，连接怪兽所连接区有怪兽特殊召唤的场合发动。从以下效果选1个适用。这个回合，自己的「拓扑冲击波龙」的效果不能有相同效果适用。
-- ●这张卡以外的场上的怪兽全部回到卡组。
-- ●场上的魔法·陷阱卡全部回到卡组。
-- ●把对方的额外卡组确认，那之内的1张除外。
local s,id,o=GetID()
-- 初始化效果函数，设置连接召唤手续、启用特殊召唤限制，并注册两个效果
function s.initial_effect(c)
	-- 添加连接召唤手续，要求使用至少2只效果怪兽作为连接素材
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkType,TYPE_EFFECT),2)
	c:EnableReviveLimit()
	-- 设置永续效果，禁止玩家在连接区域使用额外怪兽区域
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_MUST_USE_MZONE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(1,0)
	e1:SetValue(s.zonelimit)
	c:RegisterEffect(e1)
	-- 设置诱发效果，当连接怪兽所连接区有怪兽特殊召唤时发动
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))  --"发动"
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,EFFECT_COUNT_CODE_CHAIN)
	e2:SetCondition(s.econ)
	e2:SetTarget(s.etg)
	e2:SetOperation(s.eop)
	c:RegisterEffect(e2)
end
-- 计算连接区域限制值，排除当前卡的连接区域
function s.zonelimit(e)
	return 0x1f001f | (0x600060 & ~e:GetHandler():GetLinkedZone())
end
-- 判断怪兽是否在指定连接区域内
function s.cfilter(c,zone)
	local seq=c:GetSequence()
	if c:IsLocation(LOCATION_MZONE) then
		if c:IsControler(1) then seq=seq+16 end
	else
		seq=c:GetPreviousSequence()
		if c:IsPreviousControler(1) then seq=seq+16 end
	end
	return bit.extract(zone,seq)~=0
end
-- 判断是否满足效果发动条件，即连接区有怪兽特殊召唤且当前卡在额外怪兽区域
function s.econ(e,tp,eg,ep,ev,re,r,rp)
	-- 获取双方连接区域的位值并组合
	local zone=Duel.GetLinkedZone(0)+(Duel.GetLinkedZone(1)<<0x10)
	return not eg:IsContains(e:GetHandler()) and eg:IsExists(s.cfilter,1,nil,zone) and e:GetHandler():GetSequence()>4
end
-- 过滤魔法·陷阱卡的函数，判断是否能送入卡组
function s.tdfilter(c)
	return c:IsAbleToDeck() and c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 设置效果发动时的处理函数，判断是否满足发动条件
function s.etg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否有怪兽能送入卡组
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,LOCATION_MZONE,LOCATION_MZONE,1,e:GetHandler())
		-- 判断场上有无魔法·陷阱卡能送入卡组
		or Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
		-- 判断对方额外卡组是否有卡能除外
		or Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_EXTRA,1,nil) end
end
-- 设置效果发动的处理函数，选择并执行一个效果
function s.eop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断场上是否有怪兽能送入卡组且未使用过该效果
	local b1=Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,LOCATION_MZONE,LOCATION_MZONE,1,aux.ExceptThisCard(e))
		-- 判断该效果是否已在本回合使用过
		and Duel.GetFlagEffect(tp,id)==0
	-- 判断场上有无魔法·陷阱卡能送入卡组且未使用过该效果
	local b2=Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
		-- 判断该效果是否已在本回合使用过
		and Duel.GetFlagEffect(tp,id+o)==0
	-- 判断对方额外卡组是否有卡能除外且未使用过该效果
	local b3=Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_EXTRA,1,nil)
		-- 判断该效果是否已在本回合使用过
		and Duel.GetFlagEffect(tp,id+o*2)==0
	if not (b1 or b2 or b3) then return end
	-- 让玩家选择效果选项
	local op=aux.SelectFromOptions(tp,
			{b1,aux.Stringid(id,1),1},  --"怪兽全部回到卡组"
			{b2,aux.Stringid(id,2),2},  --"魔法·陷阱卡全部回到卡组"
			{b3,aux.Stringid(id,3),3})  --"除外额外卡组"
	if op==1 then
		-- 注册使用第一个效果的标识
		Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
		-- 获取场上所有能送入卡组的怪兽
		local g=Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,LOCATION_MZONE,LOCATION_MZONE,aux.ExceptThisCard(e))
		if g:GetCount()>0 then
			-- 将怪兽送入卡组并洗切卡组
			Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		end
	elseif op==2 then
		-- 注册使用第二个效果的标识
		Duel.RegisterFlagEffect(tp,id+o,RESET_PHASE+PHASE_END,0,1)
		-- 获取场上的魔法·陷阱卡
		local g=Duel.GetMatchingGroup(s.tdfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
		if g:GetCount()>0 then
			-- 将魔法·陷阱卡送入卡组并洗切卡组
			Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		end
	elseif op==3 then
		-- 注册使用第三个效果的标识
		Duel.RegisterFlagEffect(tp,id+o*2,RESET_PHASE+PHASE_END,0,1)
		-- 获取对方额外卡组的所有卡
		local g=Duel.GetFieldGroup(tp,0,LOCATION_EXTRA)
		if g:GetCount()>0 then
			-- 中断当前效果处理
			Duel.BreakEffect()
			-- 确认对方额外卡组的卡
			Duel.ConfirmCards(tp,g,true)
			-- 提示玩家选择要除外的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
			local tg=g:FilterSelect(tp,Card.IsAbleToRemove,1,1,nil)
			if tg:GetCount()>0 then
				-- 将选中的卡除外
				Duel.Remove(tg,POS_FACEUP,REASON_EFFECT)
			end
			-- 洗切对方额外卡组
			Duel.ShuffleExtra(1-tp)
		end
	end
end
