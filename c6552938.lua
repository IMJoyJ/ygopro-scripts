--RR－ラダー・ストリクス
-- 效果：
-- ①：这张卡召唤成功的场合或者用「急袭猛禽」卡的效果从手卡特殊召唤成功的场合才能发动。给与对方600伤害。
-- ②：这张卡为攻击对象的对方怪兽的攻击宣言时才能发动。从手卡把最多2只「急袭猛禽」怪兽特殊召唤。这个回合，对方不能选择这个效果特殊召唤的怪兽作为攻击对象。
function c6552938.initial_effect(c)
	-- ①：这张卡召唤成功的场合或者用「急袭猛禽」卡的效果从手卡特殊召唤成功的场合才能发动。给与对方600伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetDescription(aux.Stringid(6552938,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTarget(c6552938.damtg)
	e1:SetOperation(c6552938.damop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCondition(c6552938.damcon)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：这张卡为攻击对象的对方怪兽的攻击宣言时才能发动。从手卡把最多2只「急袭猛禽」怪兽特殊召唤。这个回合，对方不能选择这个效果特殊召唤的怪兽作为攻击对象。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(6552938,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_ATTACK_ANNOUNCE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(c6552938.spcon)
	e3:SetTarget(c6552938.sptg)
	e3:SetOperation(c6552938.spop)
	c:RegisterEffect(e3)
end
-- 检查自身是否是通过「急袭猛禽」卡的效果从手卡特殊召唤成功
function c6552938.damcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSpecialSummonSetCard(0xba) and c:IsPreviousLocation(LOCATION_HAND)
end
-- 效果①的发动准备，设置对方玩家为伤害对象并声明造成600点伤害的操作信息
function c6552938.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前连锁的对象玩家为对方玩家
	Duel.SetTargetPlayer(1-tp)
	-- 设置当前连锁的对象参数为600
	Duel.SetTargetParam(600)
	-- 设置当前连锁的操作信息为给与对方玩家600点伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,600)
end
-- 效果①的效果处理，获取目标玩家和伤害数值并给与对方伤害
function c6552938.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁设定的对象玩家和对象参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 因效果给与目标玩家对应的伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
-- 效果②的发动条件，检查自身是否被选为攻击对象
function c6552938.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前的攻击对象是否是自身
	return Duel.GetAttackTarget()==e:GetHandler()
end
-- 过滤手卡中可以特殊召唤的「急袭猛禽」怪兽
function c6552938.spfilter(c,e,tp)
	return c:IsSetCard(0xba) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的发动准备，检查自身怪兽区域是否有空位以及手卡中是否存在可特殊召唤的「急袭猛禽」怪兽，并声明特殊召唤的操作信息
function c6552938.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自身主要怪兽区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡中是否存在至少1只满足条件的「急袭猛禽」怪兽
		and Duel.IsExistingMatchingCard(c6552938.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置当前连锁的操作信息为从手卡特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果②的效果处理，计算可特殊召唤的数量，让玩家选择并特殊召唤最多2只「急袭猛禽」怪兽，并赋予它们本回合不能成为攻击对象的效果
function c6552938.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自身主要怪兽区域的可用空位数
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	if ft>2 then ft=2 end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡选择1到ft张满足条件的「急袭猛禽」怪兽
	local g=Duel.SelectMatchingCard(tp,c6552938.spfilter,tp,LOCATION_HAND,0,1,ft,nil,e,tp)
	local tc=g:GetFirst()
	while tc do
		-- 尝试将选中的怪兽以表侧表示特殊召唤到自身场上
		if Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
			-- 这个回合，对方不能选择这个效果特殊召唤的怪兽作为攻击对象。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
			-- 设置不能成为攻击对象的效果的具体判定函数
			e1:SetValue(aux.imval1)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
		end
		tc=g:GetNext()
	end
	-- 完成特殊召唤的流程
	Duel.SpecialSummonComplete()
end
