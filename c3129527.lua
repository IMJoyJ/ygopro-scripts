--眠れる羊 スケープ・ゴート
local s,id,o=GetID()
-- 初始化卡片效果，注册Activate类型的效果
function s.initial_effect(c)
	-- 记录该卡效果文本上记载着【青眼精灵龙】和【黑魔导】的卡名
	aux.AddCodeList(c,77482666,40235813)
	-- 创建一个发动时点为自由连锁的效果，效果分类包含特殊召唤、衍生物和从卡组送去墓地
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 判断是否可以发动此效果，检查玩家场上是否有空位且可以特殊召唤token怪兽
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家是否可以特殊召唤token怪兽
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id+o,0,TYPES_TOKEN_MONSTER,0,0,1,RACE_BEAST,ATTRIBUTE_EARTH,POS_FACEUP_DEFENSE) end
	-- 设置操作信息：将要特殊召唤1个衍生物
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 设置操作信息：将要特殊召唤1个怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
-- 定义过滤函数，用于检测卡组中是否存在【青眼精灵龙】且可特殊召唤
function s.spfilter(c,e,tp)
	return c:IsCode(77482666) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 发动效果时执行的操作，包括特殊召唤token和可能的额外特殊召唤
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取玩家场上可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft>4 then ft=4 end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 检查是否可以特殊召唤token怪兽且有空位
	if Duel.IsPlayerCanSpecialSummonMonster(tp,id+o,0,TYPES_TOKEN_MONSTER,0,0,1,RACE_BEAST,ATTRIBUTE_EARTH,POS_FACEUP_DEFENSE) and ft>0 then
		if ft>1 then
			local ct={}
			for i=ft,1,-1 do
				table.insert(ct,i)
			end
			-- 提示玩家选择要特殊召唤的token数量
			Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,1))
			-- 根据玩家选择确定实际要特殊召唤的token数量
			ft=Duel.AnnounceNumber(tp,1,table.unpack(ct))
		end
		for cid=1,ft do
			-- 创建一个token衍生物
			local token=Duel.CreateToken(tp,id+o*cid)
			-- 将token以防御表示特殊召唤到场上
			Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
			-- 为token设置一个可以替代其被破坏的效果
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
			e1:SetCode(EFFECT_DESTROY_REPLACE)
			e1:SetRange(LOCATION_MZONE)
			e1:SetTarget(s.destg)
			e1:SetLabel(tp)
			e1:SetValue(s.repval)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			token:RegisterEffect(e1,true)
			-- 为token设置不可被解放的效果
			local e2=Effect.CreateEffect(e:GetHandler())
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_UNRELEASABLE_SUM)
			e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e2:SetValue(1)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			token:RegisterEffect(e2,true)
		end
		-- 完成所有特殊召唤步骤
		Duel.SpecialSummonComplete()
		-- 刷新场地信息
		Duel.AdjustAll()
		-- 检查玩家场上是否有空位
		if Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			-- 检查对方场上有无怪兽
			and Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_MZONE,1,nil)
			-- 检查卡组中是否存在【青眼精灵龙】且可特殊召唤
			and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp)
			-- 询问玩家是否发动额外特殊召唤
			and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
			-- 中断当前效果处理，使后续效果视为不同时处理
			Duel.BreakEffect()
			-- 提示玩家选择要特殊召唤的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			-- 从卡组中选择1张【青眼精灵龙】进行特殊召唤
			local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
			if g:GetCount()>0 then
				-- 将选中的卡以正面表示特殊召唤到场上
				Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
			end
		end
	end
	-- 创建一个限制对方不能特殊召唤融合怪兽的效果
	local e3=Effect.CreateEffect(e:GetHandler())
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetTargetRange(1,0)
	e3:SetTarget(s.splimit)
	e3:SetReset(RESET_PHASE+PHASE_END)
	-- 注册该效果给玩家
	Duel.RegisterEffect(e3,tp)
end
-- 定义限制条件：不能特殊召唤额外卡组中的融合怪兽
function s.splimit(e,c)
	return not c:IsType(TYPE_FUSION) and c:IsLocation(LOCATION_EXTRA)
end
-- 定义过滤函数，用于检测满足条件的卡
function s.rfilter(c,tp)
	-- 检测卡是否为表侧表示且记载着【黑魔导】的卡名，并且被战斗或效果破坏但不是替代破坏
	return c:IsFaceup() and aux.IsCodeListed(c,40235813) and c:IsReason(REASON_BATTLE+REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
		and c:IsControler(tp)
end
-- 判断token是否可以被替代破坏的效果处理
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:GetControler()==c:GetOwner() and eg:IsExists(s.rfilter,1,c,tp)
		and c:IsDestructable(e) and not c:IsStatus(STATUS_DESTROY_CONFIRMED) end
	-- 询问玩家是否发动替代破坏效果
	if Duel.SelectEffectYesNo(tp,c,96) then
		-- 执行替代破坏，将token破坏
		Duel.Destroy(c,REASON_EFFECT+REASON_REPLACE)
		return true
	else return false end
end
-- 定义替代破坏值函数，用于判断是否可以替代破坏
function s.repval(e,c)
	-- 判断卡是否为表侧表示且记载着【黑魔导】的卡名，并且不是该效果的持有者且是该玩家控制
	return c:IsFaceup() and aux.IsCodeListed(c,40235813) and c~=e:GetHandler() and c:IsControler(e:GetLabel())
end
