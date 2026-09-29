--天ノ異解△シェオル
-- 效果：
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：这张卡在手卡存在，自己场上有「异解△」怪兽存在的场合才能发动。这张卡特殊召唤。
-- ②：这张卡召唤·特殊召唤的场合发动。从自己卡组上面把2张卡里侧除外。
-- ③：自己主要阶段才能发动。自己的除外状态（里侧）的最多2张「异解△」魔法·陷阱卡加入手卡（同名卡最多1张）。这个回合，自己不能把「异解△」卡以外的卡的效果发动。
local s,id,o=GetID()
-- 初始化卡片效果：注册手卡自身特召、召·特召从卡组顶里侧除外2张卡、主要阶段回收除外状态里侧「异解△」魔陷并附带发动限制的效果
function s.initial_effect(c)
	-- ①：这张卡在手卡存在，自己场上有「异解△」怪兽存在的场合才能发动。这张卡特殊召唤。
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
	-- ②：这张卡召唤·特殊召唤的场合发动。从自己卡组上面把2张卡里侧除外。
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
	-- ③：自己主要阶段才能发动。自己的除外状态（里侧）的最多2张「异解△」魔法·陷阱卡加入手卡（同名卡最多1张）。这个回合，自己不能把「异解△」卡以外的卡的效果发动。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))  --"回收"
	e4:SetCategory(CATEGORY_TOHAND)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,id+o)
	e4:SetTarget(s.thtg)
	e4:SetOperation(s.thop)
	c:RegisterEffect(e4)
end
-- 过滤自己场上表侧表示的「异解△」怪兽
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x1ed)
end
-- 效果发动条件：自己场上有「异解△」怪兽存在
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在表侧表示的「异解△」怪兽
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 效果发动目标判定：检查怪兽区域空位及自身是否可以特殊召唤
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查怪兽区域是否有可用空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：将自身特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 效果处理：将自身从手卡特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		-- 将自身表侧表示特殊召唤
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 效果发动目标判定：获取卡组顶2张卡并设置除外操作信息
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己卡组最上方的2张卡
	local dg=Duel.GetDecktopGroup(tp,2)
	if chk==0 then return true end
	-- 设置操作信息：将卡组顶的2张卡除外
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,dg,dg:GetCount(),0,0)
	-- 向对方提示发动的效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
-- 效果处理：从自己卡组上面把2张卡里侧除外并注册标记
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己卡组最上方的2张卡
	local dg=Duel.GetDecktopGroup(tp,2)
	if dg and dg:GetCount()>0 then
		-- 使紧接着的除外操作不进行洗卡检测
		Duel.DisableShuffleCheck()
		-- 将卡组顶的卡里侧除外
		if Duel.Remove(dg,POS_FACEDOWN,REASON_EFFECT)~=0 then
			-- 遍历被除外的卡片并注册效果标记
			for tc in aux.Next(dg) do
				if tc:IsFacedown() and tc:IsLocation(LOCATION_REMOVED) then
					tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,3))  --"因「天之异解△邪奥尔」被里侧除外"
				end
			end
		end
	end
end
-- 过滤除外状态（里侧）的可加入手卡的「异解△」魔法·陷阱卡
function s.thfilter(c)
	return c:IsFacedown() and c:IsSetCard(0x1ed) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 效果发动目标判定：检查除外区是否存在满足条件的卡并设置加入手卡操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查除外区是否存在可加入手卡的「异解△」魔法·陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_REMOVED,0,1,nil) end
	-- 设置操作信息：从除外区将卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_REMOVED)
	-- 向对方提示发动的效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
-- 效果处理：将除外状态（里侧）的最多2张同名最多1张的「异解△」魔法·陷阱卡加入手卡，并对本回合施加效果发动限制
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取除外区所有满足条件的「异解△」魔法·陷阱卡
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_REMOVED,0,nil)
	-- 提示选择要加入手卡的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从满足条件的卡中选择最多2张不同名的卡
	local tg=g:SelectSubGroup(tp,aux.dncheck,false,1,2)
	if tg then
		-- 将选中的卡加入手卡
		Duel.SendtoHand(tg,nil,REASON_EFFECT)
		-- 向对方展示加入手卡的卡
		Duel.ConfirmCards(1-tp,tg)
	end
	-- 这个回合，自己不能把「异解△」卡以外的卡的效果发动。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(1,0)
	e1:SetValue(s.aclimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 对玩家注册本回合效果发动的限制
	Duel.RegisterEffect(e1,tp)
end
-- 限制条件：不能发动「异解△」卡以外的卡的效果
function s.aclimit(e,re,tp)
	return not re:GetHandler():IsSetCard(0x1ed)
end
