--葬嶺異解△ヴェルヘイム
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：自己·对方的主要阶段，把手卡的这张卡给对方观看才能发动。这张卡里侧除外，6星怪兽以外的自己的除外状态（里侧）的1只「异解△」怪兽特殊召唤。
-- ②：这张卡召唤·特殊召唤的场合发动。从自己卡组上面把6张卡里侧除外。
-- ③：只要这张卡在怪兽区域存在，自己场上的其他的「异解△」卡不会被对方的效果破坏，对方不能把那些作为效果的对象。
local s,id,o=GetID()
-- 初始化卡片效果：注册展示自身里侧除外特召里侧除外「异解△」怪兽、登场卡组顶6张里侧除外以及场上其他「异解△」卡效破与取对象抗性效果
function s.initial_effect(c)
	-- ①：自己·对方的主要阶段，把手卡的这张卡给对方观看才能发动。这张卡里侧除外，6星怪兽以外的自己的除外状态（里侧）的1只「异解△」怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetHintTiming(0,TIMING_MAIN_END)
	e1:SetCondition(s.spcon)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡召唤·特殊召唤的场合发动。从自己卡组上面把6张卡里侧除外。
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
	-- ③：只要这张卡在怪兽区域存在，自己场上的其他的「异解△」卡不会被对方的效果破坏
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTargetRange(LOCATION_ONFIELD,0)
	e4:SetTarget(s.indtg)
	-- 设置抗性为不会被对方卡片的效果破坏
	e4:SetValue(aux.indoval)
	c:RegisterEffect(e4)
	-- 对方不能把那些作为效果的对象。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e5:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e5:SetRange(LOCATION_MZONE)
	e5:SetTargetRange(LOCATION_ONFIELD,0)
	e5:SetTarget(s.indtg)
	-- 设置抗性为不能成为对方卡片的效果对象
	e5:SetValue(aux.tgoval)
	c:RegisterEffect(e5)
end
-- 特殊召唤效果的发动时点检查：仅在双方主要阶段可以发动
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前是否处于主要阶段
	return Duel.IsMainPhase()
end
-- 发动代价：把手卡的这张卡给对方观看
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsPublic() end
end
-- 过滤6星怪兽以外的自己的除外状态（里侧）的「异解△」怪兽
function s.spfilter(c,e,tp)
	return c:IsFacedown() and c:IsSetCard(0x1ed) and c:IsType(TYPE_MONSTER) and not c:IsLevel(6)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 特殊召唤效果的发动条件检查与操作信息设置
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自己怪兽区域是否有可用空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查除外区是否存在6星以外里侧表示且可特殊召唤的「异解△」怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_REMOVED,0,1,nil,e,tp)
		and c:IsAbleToRemove(tp,POS_FACEDOWN) end
	-- 设置操作信息：从除外区特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_REMOVED)
end
-- 将自身里侧除外，并从除外区特殊召唤6星以外里侧表示的1只「异解△」怪兽
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 将手卡的这张卡以里侧表示除外
	if c:IsRelateToChain() and Duel.Remove(c,POS_FACEDOWN,REASON_EFFECT)~=0 then
		if c:IsFacedown() and c:IsLocation(LOCATION_REMOVED) then
			c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,3))  --"因「葬岭异解△危尔海姆」①被里侧除外"
		end
		-- 检查自己怪兽区域是否有可用空位
		if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
			-- 提示玩家选择要特殊召唤的怪兽
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			-- 从除外区选择6星以外里侧表示的1只「异解△」怪兽
			local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
			if #g>0 then
				-- 将选中的怪兽表侧表示特殊召唤
				Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
			end
		end
	end
end
-- 除外效果的发动目标判定及操作信息设置
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己卡组最上面的6张卡
	local dg=Duel.GetDecktopGroup(tp,6)
	if chk==0 then return true end
	-- 设置操作信息：将卡组顶6张卡除外
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,dg,dg:GetCount(),0,0)
	-- 向对方提示发动了除外效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
-- 从自己卡组上面把6张卡以里侧表示除外
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己卡组最上面的6张卡
	local dg=Duel.GetDecktopGroup(tp,6)
	if dg and dg:GetCount()>0 then
		-- 使紧接着的除外操作不进行洗切卡组检查
		Duel.DisableShuffleCheck()
		-- 将卡组顶部的6张卡以里侧表示除外
		if Duel.Remove(dg,POS_FACEDOWN,REASON_EFFECT)~=0 then
			-- 遍历成功里侧除外的卡片并注册标记提示
			for tc in aux.Next(dg) do
				if tc:IsFacedown() and tc:IsLocation(LOCATION_REMOVED) then
					tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,4))  --"因「葬岭异解△危尔海姆」②被里侧除外"
				end
			end
		end
	end
end
-- 过滤自己场上其他的「异解△」卡
function s.indtg(e,c)
	return c~=e:GetHandler() and c:IsSetCard(0x1ed)
end
