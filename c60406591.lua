--デモンバルサム・シード
-- 效果：
-- 自己场上表侧攻击表示存在的怪兽被战斗破坏时才能发动。那次战斗让自己受到的战斗伤害每有500分，在自己场上把1只「魔界凤仙花衍生物」（植物族·暗·1星·攻/守100）特殊召唤。
function c60406591.initial_effect(c)
	-- 自己场上表侧攻击表示存在的怪兽被战斗破坏时才能发动。那次战斗让自己受到的战斗伤害每有500分，在自己场上把1只「魔界凤仙花衍生物」（植物族·暗·1星·攻/守100）特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(c60406591.condition)
	e1:SetTarget(c60406591.target)
	e1:SetOperation(c60406591.activate)
	c:RegisterEffect(e1)
	if not c60406591.global_check then
		c60406591.global_check=true
		c60406591[0]=nil
		c60406591[1]=nil
		c60406591[2]=nil
		-- 那次战斗让自己受到的战斗伤害每有500分
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_BATTLE_DAMAGE)
		ge1:SetOperation(c60406591.checkop)
		-- 注册全局环境效果，用于在发生战斗伤害时记录受到的伤害数值、受伤害玩家以及进行战斗的怪兽
		Duel.RegisterEffect(ge1,0)
		-- 那次战斗让自己受到的战斗伤害每有500分
		local ge2=Effect.CreateEffect(c)
		ge2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge2:SetCode(EVENT_PHASE_START+PHASE_DRAW)
		ge2:SetOperation(c60406591.clear)
		-- 注册全局环境效果，在每个回合的抽卡阶段开始时清除上一回合记录的战斗伤害相关数据
		Duel.RegisterEffect(ge2,0)
	end
end
-- 战斗伤害发生时的记录操作：保存受伤害的玩家、计算受到的战斗伤害除以500的商（即特招数量）、以及保存与被破坏怪兽进行战斗的对方怪兽
function c60406591.checkop(e,tp,eg,ep,ev,re,r,rp)
	c60406591[0]=ep
	c60406591[1]=math.floor(ev/500)
	c60406591[2]=eg:GetFirst():GetBattleTarget()
end
-- 清除上一回合保存的受伤害玩家、特招数量和战斗怪兽的记录
function c60406591.clear(e,tp,eg,ep,ev,re,r,rp)
	c60406591[0]=nil
	c60406591[1]=nil
	c60406591[2]=nil
end
-- 发动条件判定：受伤害的玩家是自己，且被战斗破坏送去墓地的怪兽数量为1，且该怪兽正是刚才进行战斗并导致自己受到伤害的那只怪兽
function c60406591.condition(e,tp,eg,ep,ev,re,r,rp)
	return c60406591[0]==tp and eg:GetCount()==1 and eg:GetFirst()==c60406591[2]
end
-- 发动时的效果处理可行性检测：特招数量大于0，且在特招多于1只时未受到“青眼精灵龙”等限制同时特招2只以上怪兽的效果影响，且场上有足够的怪兽区域，且可以特殊召唤该衍生物
function c60406591.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=c60406591[1]
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return ct>0 and (ct==1 or not Duel.IsPlayerAffectedByEffect(tp,59822133))
		-- 检测自己场上的主要怪兽区域空位数是否大于或等于需要特殊召唤的衍生物数量
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>=ct
		-- 检测玩家是否可以特殊召唤该特定属性、种族、等级和攻守数值的衍生物怪兽
		and Duel.IsPlayerCanSpecialSummonMonster(tp,60406592,0,TYPES_TOKEN_MONSTER,100,100,1,RACE_PLANT,ATTRIBUTE_DARK) end
	-- 设置连锁信息：包含产生衍生物的效果，预计产生的数量为ct
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,ct,0,0)
	-- 设置连锁信息：包含特殊召唤的效果，预计特殊召唤的数量为ct
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,ct,0,0)
end
-- 效果处理开始：再次检测特招数量、青眼精灵龙的限制、怪兽区域空位数以及是否能特招该衍生物，若不满足条件则直接结束处理
function c60406591.activate(e,tp,eg,ep,ev,re,r,rp)
	local ct=c60406591[1]
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if (ct>1 and Duel.IsPlayerAffectedByEffect(tp,59822133))
		-- 效果处理时，如果自己场上的主要怪兽区域空位数小于需要特殊召唤的衍生物数量，则不处理效果
		or Duel.GetLocationCount(tp,LOCATION_MZONE)<ct
		-- 效果处理时，如果玩家无法特殊召唤该衍生物怪兽，则不处理效果
		or not Duel.IsPlayerCanSpecialSummonMonster(tp,60406592,0,TYPES_TOKEN_MONSTER,100,100,1,RACE_PLANT,ATTRIBUTE_DARK) then return end
	for i=1,ct do
		-- 在内存中创建一张卡号为60406592的「魔界凤仙花衍生物」卡片
		local token=Duel.CreateToken(tp,60406592)
		-- 将创建的衍生物以表侧表示特殊召唤到自己场上（作为多只特殊召唤的其中一步）
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
	end
	-- 完成这一组特殊召唤的处理，使所有通过SpecialSummonStep特殊召唤的怪兽正式登场并触发相关事件
	Duel.SpecialSummonComplete()
end
