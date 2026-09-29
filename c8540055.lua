--碧ノ異解△トゥオネラ
-- 效果：
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：这张卡在手卡存在，对方场上的怪兽数量比自己场上的怪兽多的场合才能发动。这张卡特殊召唤。
-- ②：这张卡召唤·特殊召唤的场合发动。从自己卡组上面把3张卡里侧除外。
-- ③：自己主要阶段才能发动。自己的除外状态（里侧）的1只5星以上的「异解△」怪兽特殊召唤。这个回合，自己不能把「异解△」卡以外的卡的效果发动。
local s,id,o=GetID()
-- 初始化卡片效果
function s.initial_effect(c)
	-- 这个卡名的①③的效果1回合各能使用1次。①：这张卡在手卡存在，对方场上的怪兽数量比自己场上的怪兽多的场合才能发动。这张卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡召唤·特殊召唤的场合发动。从自己卡组上面把3张卡里侧除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"除外"
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetTarget(s.rmtg)
	e2:SetOperation(s.rmop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	-- ③：自己主要阶段才能发动。自己的除外状态（里侧）的1只5星以上的「异解△」怪兽特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))  --"特殊召唤"
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,id+o)
	e4:SetTarget(s.sptg2)
	e4:SetOperation(s.spop2)
	c:RegisterEffect(e4)
end
-- 效果发动条件：对方场上的怪兽数量比自己场上的怪兽多
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 比较双方场上的怪兽数量
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)<Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)
end
-- 效果发动检查与设置操作信息：从手卡特殊召唤自身
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 确认怪兽区有空位且自身可以特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：特殊召唤自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 效果处理：这张卡从手卡特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		-- 将这张卡表侧表示特殊召唤
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 效果发动检查与设置操作信息：从卡组上面把3张卡里侧除外
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取卡组最上方的3张卡
	local dg=Duel.GetDecktopGroup(tp,3)
	if chk==0 then return true end
	-- 设置操作信息：将卡组顶端的3张卡除外
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,dg,dg:GetCount(),0,0)
	-- 向对方提示选择发动的效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
-- 效果处理：从自己卡组上面把3张卡里侧除外
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取卡组最上方的3张卡
	local dg=Duel.GetDecktopGroup(tp,3)
	if dg and dg:GetCount()>0 then
		-- 使后续除外操作不触发洗切卡组检查
		Duel.DisableShuffleCheck()
		-- 将卡组顶端的卡以里侧表示除外
		if Duel.Remove(dg,POS_FACEDOWN,REASON_EFFECT)~=0 then
			-- 遍历被除外的卡片并给里侧除外的卡添加客户端标记
			for tc in aux.Next(dg) do
				if tc:IsFacedown() and tc:IsLocation(LOCATION_REMOVED) then
					tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,3))  --"因「碧之异解△屠奥内拉」被里侧除外"
				end
			end
		end
	end
end
-- 过滤条件：里侧除外状态的5星以上「异解△」怪兽
function s.spfilter(c,e,tp)
	return c:IsFacedown() and c:IsSetCard(0x1ed) and c:IsLevelAbove(5)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动检查与设置操作信息：特殊召唤除外区的「异解△」怪兽
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 确认怪兽区有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 确认除外区存在满足条件的怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 设置操作信息：特殊召唤除外区的1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_REMOVED)
	-- 向对方提示选择发动的效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
-- 效果处理：特殊召唤里侧除外的「异解△」怪兽，并施加发动手牌/场上卡片效果的限制
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 确认怪兽区有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 提示选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 选择1只里侧除外的5星以上「异解△」怪兽
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
		if #g>0 then
			-- 将选中的怪兽表侧表示特殊召唤
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
	-- 这个回合，自己不能把「异解△」卡以外的卡的效果发动。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(1,0)
	e1:SetValue(s.aclimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 对玩家注册本回合不能发动「异解△」卡以外卡片效果的限制
	Duel.RegisterEffect(e1,tp)
end
-- 限制判定函数：不能发动「异解△」卡以外的卡的效果
function s.aclimit(e,re,tp)
	return not re:GetHandler():IsSetCard(0x1ed)
end
