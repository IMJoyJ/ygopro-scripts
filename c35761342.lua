--虚ノ異解△ゲヘナ
-- 效果：
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：这张卡在手卡存在，自己场上没有怪兽存在的场合才能发动。这张卡特殊召唤。
-- ②：这张卡召唤·特殊召唤的场合发动。从自己卡组上面把1张卡里侧除外。
-- ③：自己主要阶段才能发动。「虚之异解△盖赫纳」以外的自己的除外状态（里侧）的最多2只「异解△」怪兽加入手卡（同名卡最多1张）。这个回合，自己不能把「异解△」卡以外的卡的效果发动。
local s,id,o=GetID()
-- 注册卡片初始效果：①自己场上无怪兽时从手卡特召；②召唤·特殊召唤成功时卡组顶端里侧除外1张卡；③自己主要阶段回收除外状态里侧异解怪兽并施加发动限制
function s.initial_effect(c)
	-- 这个卡名的①③的效果1回合各能使用1次。①：这张卡在手卡存在，自己场上没有怪兽存在的场合才能发动。这张卡特殊召唤。
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
	-- ②：这张卡召唤·特殊召唤的场合发动。从自己卡组上面把1张卡里侧除外。
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
	-- ③：自己主要阶段才能发动。「虚之异解△盖赫纳」以外的自己的除外状态（里侧）的最多2只「异解△」怪兽加入手卡（同名卡最多1张）。
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
-- ①效果的发动条件：自己场上没有怪兽存在
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己怪兽区是否存在怪兽
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
end
-- ①效果的目标：检查主要怪兽区空格并确认自身能否特殊召唤
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查主要怪兽区是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤自身的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- ①效果的处理：从手卡特殊召唤这张卡
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		-- 将这张卡以表侧表示特殊召唤
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- ②效果的目标：获取卡组顶端1张卡并设置除外操作信息
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自身卡组顶端的1张卡
	local dg=Duel.GetDecktopGroup(tp,1)
	if chk==0 then return true end
	-- 设置除外卡组顶端1张卡的操作信息
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,dg,dg:GetCount(),0,0)
	-- 向对方提示发动的效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
-- ②效果的处理：将卡组顶端的1张卡里侧除外
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自身卡组顶端的1张卡
	local dg=Duel.GetDecktopGroup(tp,1)
	if dg and dg:GetCount()>0 then
		-- 禁用下一次操作的洗卡检测
		Duel.DisableShuffleCheck()
		-- 将卡组顶端的卡以里侧表示除外
		if Duel.Remove(dg,POS_FACEDOWN,REASON_EFFECT)~=0 then
			-- 遍历被里侧除外的卡片以添加客户端提示
			for tc in aux.Next(dg) do
				if tc:IsFacedown() and tc:IsLocation(LOCATION_REMOVED) then
					tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,3))  --"因「虚之异解△盖赫纳」被里侧除外"
				end
			end
		end
	end
end
-- 过滤除外状态里侧表示、同名卡以外且可加入手卡的「异解△」怪兽
function s.thfilter(c)
	return c:IsFacedown() and not c:IsCode(id) and c:IsSetCard(0x1ed) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- ③效果的目标：检查除外区是否存在目标怪兽并设置加入手卡操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查除外区是否存在满足条件的里侧表示「异解△」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_REMOVED,0,1,nil) end
	-- 设置将除外区卡片加入手卡的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_REMOVED)
	-- 向对方提示发动的效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
-- ③效果的处理：将除外状态里侧表示的最多2只卡名不同的「异解△」怪兽加入手卡，并在本回合限制发动非「异解△」卡的效果
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取除外区所有满足条件的里侧表示「异解△」怪兽
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_REMOVED,0,nil)
	-- 提示选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从符合条件的怪兽中选择最多2只卡名不同的怪兽
	local tg=g:SelectSubGroup(tp,aux.dncheck,false,1,2)
	if tg then
		-- 将选中的怪兽加入手卡
		Duel.SendtoHand(tg,nil,REASON_EFFECT)
		-- 向对方确认加入手卡的卡片
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
	-- 为玩家注册本回合不能发动非「异解△」卡效果的限制
	Duel.RegisterEffect(e1,tp)
end
-- 过滤非「异解△」卡的发动限制
function s.aclimit(e,re,tp)
	return not re:GetHandler():IsSetCard(0x1ed)
end
