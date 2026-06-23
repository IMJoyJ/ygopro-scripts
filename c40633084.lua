--騎甲虫歩兵分隊
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：把衍生物以外的自己场上1只昆虫族怪兽解放才能发动。那只怪兽的原本攻击力每1000最多1只的「骑甲虫衍生物」（昆虫族·地·3星·攻/守1000）在自己场上特殊召唤。
function c40633084.initial_effect(c)
	-- ①：把衍生物以外的自己场上1只昆虫族怪兽解放才能发动。那只怪兽的原本攻击力每1000最多1只的「骑甲虫衍生物」（昆虫族·地·3星·攻/守1000）在自己场上特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(40633084,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,40633084+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(c40633084.cost)
	e1:SetTarget(c40633084.target)
	e1:SetOperation(c40633084.activate)
	c:RegisterEffect(e1)
end
-- 设置发动时的标签为100，表示已进入发动阶段
function c40633084.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	if chk==0 then return true end
end
-- 过滤函数，用于筛选满足条件的昆虫族怪兽（非衍生物、攻击力≥1000、在场且可解放）
function c40633084.cfilter(c,tp)
	return c:IsType(TYPE_MONSTER) and not c:IsType(TYPE_TOKEN) and c:IsRace(RACE_INSECT) and c:GetBaseAttack()>=1000
		-- 检查目标怪兽是否在场且有可用怪兽区
		and Duel.GetMZoneCount(tp,c)>0 and (c:IsControler(tp) or c:IsFaceup())
end
-- 效果处理函数，判断是否满足发动条件并选择解放的怪兽
function c40633084.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if e:GetLabel()~=100 then return false end
		e:SetLabel(0)
		-- 检查场上是否存在满足条件的可解放怪兽
		return Duel.CheckReleaseGroup(tp,c40633084.cfilter,1,nil,tp)
			-- 检查玩家是否可以特殊召唤指定的衍生物
			and Duel.IsPlayerCanSpecialSummonMonster(tp,64213018,0x170,TYPES_TOKEN_MONSTER,1000,1000,3,RACE_INSECT,ATTRIBUTE_EARTH)
	end
	-- 选择1只满足条件的怪兽进行解放
	local g=Duel.SelectReleaseGroup(tp,c40633084.cfilter,1,1,nil,tp)
	local atk=g:GetFirst():GetBaseAttack()
	-- 将选中的怪兽解放作为发动代价
	Duel.Release(g,REASON_COST)
	e:SetLabel(math.floor(atk/1000))
	-- 设置操作信息：将要特殊召唤1只衍生物
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 设置操作信息：将要特殊召唤1只衍生物
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
end
-- 效果发动处理函数，计算可召唤衍生物数量并执行特殊召唤
function c40633084.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取玩家场上可用的怪兽区数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 检查是否满足特殊召唤衍生物的条件
	if ft<=0 or not Duel.IsPlayerCanSpecialSummonMonster(tp,64213018,0x170,TYPES_TOKEN_MONSTER,1000,1000,3,RACE_INSECT,ATTRIBUTE_EARTH) then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	local ct=(Duel.IsPlayerAffectedByEffect(tp,59822133)) and 1 or math.min(ft,e:GetLabel())
	local range={}
	for i=1,ct do
		table.insert(range,i)
	end
	-- 提示玩家选择要特殊召唤的衍生物数量
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(40633084,1))  --"请选择要特殊召唤的衍生物的数量"
	-- 让玩家宣言要特殊召唤的衍生物数量
	local n=Duel.AnnounceNumber(tp,table.unpack(range))
	local sg=Group.CreateGroup()
	for i=1,n do
		-- 创建指定编号的衍生物卡片
		local token=Duel.CreateToken(tp,40633085)
		sg:AddCard(token)
	end
	if #sg<=0 then return end
	-- 将创建的衍生物特殊召唤到场上
	Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
end
