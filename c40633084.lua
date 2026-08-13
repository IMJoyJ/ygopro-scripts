--騎甲虫歩兵分隊
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：把衍生物以外的自己场上1只昆虫族怪兽解放才能发动。那只怪兽的原本攻击力每1000最多1只的「骑甲虫衍生物」（昆虫族·地·3星·攻/守1000）在自己场上特殊召唤。
function c40633084.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：把衍生物以外的自己场上1只昆虫族怪兽解放才能发动。那只怪兽的原本攻击力每1000最多1只的「骑甲虫衍生物」（昆虫族·地·3星·攻/守1000）在自己场上特殊召唤。
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
-- cost函数：设定效果标签为100，标记cost检查已通过；chk==0时直接返回true，实际解放操作在target阶段处理。
function c40633084.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	if chk==0 then return true end
end
-- 筛选可解放的昆虫族怪兽：必须是昆虫族、非衍生物、原本攻击力不低于1000，且解放后自己仍有可用怪兽区；自己控制的怪兽不限表里，对方控制的怪兽必须表侧表示。
function c40633084.cfilter(c,tp)
	return c:IsType(TYPE_MONSTER) and not c:IsType(TYPE_TOKEN) and c:IsRace(RACE_INSECT) and c:GetBaseAttack()>=1000
		-- 追加条件：解放该怪兽后自己仍有至少1个可用怪兽区，且该怪兽是自己控制（不限表示形式）或对方表侧表示的怪兽。
		and Duel.GetMZoneCount(tp,c)>0 and (c:IsControler(tp) or c:IsFaceup())
end
-- target函数：先确认cost标记并重置、检查可解放怪兽和可特招token；然后让玩家选择1只符合条件的昆虫族怪兽解放，按原本攻击力/1000计算最多token数量存入标签，并登记后续将进行token特殊召唤。
function c40633084.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if e:GetLabel()~=100 then return false end
		e:SetLabel(0)
		-- 检查自己场上是否存在至少1只满足cfilter条件的可解放昆虫族怪兽作为cost来源。
		return Duel.CheckReleaseGroup(tp,c40633084.cfilter,1,nil,tp)
			-- 检查自己此时能否特殊召唤「骑甲虫衍生物」（64213018，昆虫族·地·3星·攻/守1000的衍生物）。
			and Duel.IsPlayerCanSpecialSummonMonster(tp,64213018,0x170,TYPES_TOKEN_MONSTER,1000,1000,3,RACE_INSECT,ATTRIBUTE_EARTH)
	end
	-- 让玩家选择1只满足条件的昆虫族怪兽作为解放cost。
	local g=Duel.SelectReleaseGroup(tp,c40633084.cfilter,1,1,nil,tp)
	local atk=g:GetFirst():GetBaseAttack()
	-- 将所选怪兽以COST原因解放，完成发动cost的支付。
	Duel.Release(g,REASON_COST)
	e:SetLabel(math.floor(atk/1000))
	-- 登记操作信息：本效果将生成衍生物（预计1只，具体数量效果处理时确定）；用于外界对效果的连锁/判定。
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 登记操作信息：本效果将进行特殊召唤（预计由tp方特殊召唤1只怪兽，对象处理时确定）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
end
-- activate函数：效果处理时若没有空怪兽区或不能特招衍生物则直接结束；否则根据青眼精灵龙限制（最多1只）与可用区域、标签token上限计算可特招数量范围，让玩家选择数量，生成对应数量的骑甲虫衍生物并特殊召唤。
function c40633084.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上当前可用的主要怪兽区数量。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 若可用怪兽区为0或当前不能特殊召唤「骑甲虫衍生物」，则效果处理中止。
	if ft<=0 or not Duel.IsPlayerCanSpecialSummonMonster(tp,64213018,0x170,TYPES_TOKEN_MONSTER,1000,1000,3,RACE_INSECT,ATTRIBUTE_EARTH) then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	local ct=(Duel.IsPlayerAffectedByEffect(tp,59822133)) and 1 or math.min(ft,e:GetLabel())
	local range={}
	for i=1,ct do
		table.insert(range,i)
	end
	-- 向玩家显示选择特殊召唤衍生物数量的提示（使用该卡第2个效果文本）。
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(40633084,1))  --"请选择要特殊召唤的衍生物的数量"
	-- 玩家宣言一个数字（1~ct之间）作为实际特殊召唤的衍生物数量。
	local n=Duel.AnnounceNumber(tp,table.unpack(range))
	local sg=Group.CreateGroup()
	for i=1,n do
		-- 创建1只卡号为40633085的「骑甲虫衍生物」token，控制者为tp。
		local token=Duel.CreateToken(tp,40633085)
		sg:AddCard(token)
	end
	if #sg<=0 then return end
	-- 将生成的衍生物组以表侧表示特殊召唤到tp场上。
	Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
end
