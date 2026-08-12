--トリックスター・フェス
-- 效果：
-- 这个卡名的卡在1回合只能发动1张，这张卡发动的回合，自己不是「淘气仙星」怪兽不能召唤·特殊召唤。
-- ①：在自己场上把2只「淘气仙星衍生物」（天使族·光·1星·攻/守0）特殊召唤。
-- ②：从额外卡组特殊召唤的自己场上的「淘气仙星」怪兽被战斗·效果破坏的场合，可以作为代替把墓地的这张卡除外。
function c62481203.initial_effect(c)
	-- ①：在自己场上把2只「淘气仙星衍生物」（天使族·光·1星·攻/守0）特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,62481203+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(c62481203.cost)
	e1:SetTarget(c62481203.target)
	e1:SetOperation(c62481203.activate)
	c:RegisterEffect(e1)
	-- ②：从额外卡组特殊召唤的自己场上的「淘气仙星」怪兽被战斗·效果破坏的场合，可以作为代替把墓地的这张卡除外。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetTarget(c62481203.reptg)
	e2:SetValue(c62481203.repval)
	e2:SetOperation(c62481203.repop)
	c:RegisterEffect(e2)
	-- 添加召唤「淘气仙星」以外怪兽的计数器
	Duel.AddCustomActivityCounter(62481203,ACTIVITY_SUMMON,c62481203.counterfilter)
	-- 添加特殊召唤「淘气仙星」以外怪兽的计数器
	Duel.AddCustomActivityCounter(62481203,ACTIVITY_SPSUMMON,c62481203.counterfilter)
end
-- 过滤函数，检查怪兽是否为「淘气仙星」怪兽
function c62481203.counterfilter(c)
	return c:IsSetCard(0xfb)
end
-- 发动代价判定，检查本回合是否召唤或特殊召唤过「淘气仙星」以外的怪兽
function c62481203.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查本回合是否进行过「淘气仙星」以外怪兽的召唤
	if chk==0 then return Duel.GetCustomActivityCount(62481203,tp,ACTIVITY_SUMMON)==0
		-- 检查本回合是否进行过「淘气仙星」以外怪兽的特殊召唤
		and Duel.GetCustomActivityCount(62481203,tp,ACTIVITY_SPSUMMON)==0 end
	-- 这张卡发动的回合，自己不是「淘气仙星」怪兽不能召唤·特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c62481203.sumlimit)
	-- 注册限制玩家不能特殊召唤「淘气仙星」以外怪兽的效果
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_SUMMON)
	-- 注册限制玩家不能召唤「淘气仙星」以外怪兽的效果
	Duel.RegisterEffect(e2,tp)
end
-- 限制不能召唤·特殊召唤的怪兽过滤函数（非「淘气仙星」怪兽）
function c62481203.sumlimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsSetCard(0xfb)
end
-- 效果发动时的目标选择与合法性检测
function c62481203.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检查自己场上的怪兽区域空位数是否大于1
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		-- 检查玩家是否可以特殊召唤「淘气仙星衍生物」
		and Duel.IsPlayerCanSpecialSummonMonster(tp,51208047,0xfb,TYPES_TOKEN_MONSTER,0,0,1,RACE_FAIRY,ATTRIBUTE_LIGHT) end
	-- 设置操作信息：产生2只衍生物
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,2,0,0)
	-- 设置操作信息：特殊召唤2只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,0,0)
end
-- 效果处理函数，在场上特殊召唤2只「淘气仙星衍生物」
function c62481203.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 检查怪兽区域空位数是否大于1
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		-- 检查是否可以特殊召唤「淘气仙星衍生物」
		and Duel.IsPlayerCanSpecialSummonMonster(tp,51208047,0xfb,TYPES_TOKEN_MONSTER,0,0,1,RACE_FAIRY,ATTRIBUTE_LIGHT) then
		for i=1,2 do
			-- 创建「淘气仙星衍生物」卡片数据
			local token=Duel.CreateToken(tp,62481204)
			-- 逐步特殊召唤衍生物（表侧表示）
			Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
		end
		-- 完成特殊召唤流程
		Duel.SpecialSummonComplete()
	end
end
-- 过滤需要代替破坏的卡：从额外卡组特殊召唤的自己场上的「淘气仙星」怪兽被战斗·效果破坏
function c62481203.repfilter(c,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsLocation(LOCATION_MZONE) and c:IsSummonLocation(LOCATION_EXTRA) and c:IsSetCard(0xfb)
		and c:IsReason(REASON_BATTLE+REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
end
-- 代替破坏效果的目标判定，询问玩家是否代替破坏
function c62481203.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(c62481203.repfilter,1,nil,tp) and e:GetHandler():IsAbleToRemove() end
	-- 询问玩家是否发动代替破坏的效果
	return Duel.SelectEffectYesNo(tp,e:GetHandler(),96)
end
-- 代替破坏的价值判定，确定受保护的怪兽
function c62481203.repval(e,c)
	return c62481203.repfilter(c,e:GetHandlerPlayer())
end
-- 代替破坏的效果处理，将墓地的这张卡除外
function c62481203.repop(e,tp,eg,ep,ev,re,r,rp)
	-- 将墓地的这张卡除外作为代替
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT+REASON_REPLACE)
end
