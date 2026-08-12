--絶無なる獄神界－ヴィードリア
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：把额外卡组1只「狱神」怪兽给对方观看才能发动。选自己1张手卡里侧除外。那之后，从卡组选有给人观看的怪兽的卡名记述的1只怪兽加入手卡或特殊召唤。
-- ②：对方场上的怪兽的攻击力下降除外状态的卡数量×100。
-- ③：只要自己场上有「创狱神 涅瓦」「坏狱神 朱庇特」「调狱神 朱诺拉」全部存在，对方不能把墓地的卡的效果发动。
local s,id,o=GetID()
-- 初始化效果函数，注册所有效果
function s.initial_effect(c)
	-- 记录该卡效果文本中记载的其他卡名
	aux.AddCodeList(c,53589300,68231287,5914858)
	-- ①效果：发动
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"发动"
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①效果：检索效果
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"检索效果"
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	-- ②效果：对方场上的怪兽的攻击力下降除外状态的卡数量×100
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetRange(LOCATION_FZONE)
	e3:SetTargetRange(0,LOCATION_MZONE)
	e3:SetValue(s.value1)
	c:RegisterEffect(e3)
	-- ③效果：只要自己场上有「创狱神 涅瓦」「坏狱神 朱庇特」「调狱神 朱诺拉」全部存在，对方不能把墓地的卡的效果发动
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetCode(EFFECT_CANNOT_ACTIVATE)
	e4:SetRange(LOCATION_FZONE)
	e4:SetTargetRange(0,1)
	e4:SetCondition(s.actcon)
	e4:SetValue(s.aclimit)
	c:RegisterEffect(e4)
end
-- ②效果的攻击力计算函数
function s.value1(e,c)
	-- 返回除外状态的卡数量乘以-100作为攻击力变化值
	return Duel.GetFieldGroupCount(c:GetControler(),LOCATION_REMOVED,LOCATION_REMOVED)*(-100)
end
-- 筛选额外卡组中「狱神」怪兽的过滤器
function s.cfilter(c,e,tp)
	-- 筛选额外卡组中「狱神」怪兽并检查其是否能检索的条件
	return c:IsSetCard(0x1ce) and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil,e,tp,c:GetCode())
end
-- 检索卡组中符合条件的怪兽的过滤器
function s.thfilter(c,e,tp,cid)
	-- 判断卡是否记载了指定卡号且为怪兽类型
	if not (aux.IsCodeListed(c,cid) and c:IsType(TYPE_MONSTER)) then return false end
	-- 获取玩家场上可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	return c:IsAbleToHand() or (ft>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false))
end
-- 筛选手卡中可除外的卡的过滤器
function s.rmfilter(c,tp)
	return c:IsAbleToRemove(tp,POS_FACEDOWN)
end
-- ①效果的发动条件检查函数
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查额外卡组是否存在「狱神」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp)
		-- 检查手卡是否存在可除外的卡
		and Duel.IsExistingMatchingCard(s.rmfilter,tp,LOCATION_HAND,0,1,nil,tp) end
	-- 获取额外卡组中所有「狱神」怪兽组成的Group
	local exg=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_EXTRA,0,nil,e,tp)
	-- 提示玩家选择给对方确认的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	local fc=exg:Select(tp,1,1,nil):GetFirst()
	e:SetLabel(fc:GetCode())
	-- 向对方确认所选的卡
	Duel.ConfirmCards(1-tp,fc)
	-- 设置操作信息，表示将要除外手卡中的1张卡
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_HAND)
end
-- ①效果的处理函数
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local cid=e:GetLabel()
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择手卡中可除外的卡
	local rg=Duel.SelectMatchingCard(tp,s.rmfilter,tp,LOCATION_HAND,0,1,1,nil,tp)
	local rc=rg:GetFirst()
	-- 判断所选卡是否成功除外并处于除外状态
	if rc and Duel.Remove(rc,POS_FACEDOWN,REASON_EFFECT)>0 and rc:IsLocation(LOCATION_REMOVED) then
		-- 提示玩家选择要操作的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
		-- 从卡组中选择符合条件的卡
		local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,cid)
		local tc=g:GetFirst()
		-- 获取玩家场上可用的怪兽区域数量
		local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
		if tc then
			-- 中断当前效果，使之后的效果处理视为不同时处理
			Duel.BreakEffect()
			local spchk=tc:IsCanBeSpecialSummoned(e,0,tp,false,false) and ft>0
			-- 判断是否选择回手或特殊召唤
			if tc:IsAbleToHand() and (not spchk or Duel.SelectOption(tp,1190,1152)==0) then
				-- 将卡送入手卡
				Duel.SendtoHand(tc,nil,REASON_EFFECT)
				-- 向对方确认所选的卡
				Duel.ConfirmCards(1-tp,tc)
			elseif spchk then
				-- 特殊召唤卡到场上
				Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
			end
		end
	end
end
-- 筛选场上的特定卡的过滤器
function s.cofilter(c,cid)
	return c:IsFaceup() and c:IsCode(cid)
end
-- ③效果的发动条件检查函数
function s.actcon(e)
	-- 检查自己场上是否存在「创狱神 涅瓦」
	return Duel.IsExistingMatchingCard(s.cofilter,e:GetHandlerPlayer(),LOCATION_ONFIELD,0,1,nil,53589300)
		-- 检查自己场上是否存在「坏狱神 朱庇特」
		and Duel.IsExistingMatchingCard(s.cofilter,e:GetHandlerPlayer(),LOCATION_ONFIELD,0,1,nil,68231287)
		-- 检查自己场上是否存在「调狱神 朱诺拉」
		and Duel.IsExistingMatchingCard(s.cofilter,e:GetHandlerPlayer(),LOCATION_ONFIELD,0,1,nil,5914858)
end
-- ③效果的限制函数，限制对方不能发动墓地的效果
function s.aclimit(e,re,tp)
	return re:GetActivateLocation()==LOCATION_GRAVE
end
