--リンク・ディヴォーティー
-- 效果：
-- 4星以下的电子界族怪兽1只
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡特殊召唤成功的场合发动。这个回合，自己不能把连接3以上的连接怪兽连接召唤。
-- ②：互相连接状态的这张卡被解放的场合才能发动。在自己场上把2只「连接衍生物」（电子界族·光·1星·攻/守0）特殊召唤。
function c48068378.initial_effect(c)
	c:EnableReviveLimit()
	-- 为卡片添加连接召唤手续，要求使用1到1个满足过滤条件的怪兽作为连接素材
	aux.AddLinkProcedure(c,c48068378.matfilter,1,1)
	-- ①：这张卡特殊召唤成功的场合发动。这个回合，自己不能把连接3以上的连接怪兽连接召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(48068378,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetOperation(c48068378.limop)
	c:RegisterEffect(e1)
	-- ②：互相连接状态的这张卡被解放的场合才能发动。在自己场上把2只「连接衍生物」（电子界族·光·1星·攻/守0）特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(48068378,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_RELEASE)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,48068378)
	e2:SetCondition(c48068378.spcon)
	e2:SetTarget(c48068378.sptg)
	e2:SetOperation(c48068378.spop)
	c:RegisterEffect(e2)
	-- 当此卡离开场上的时候，记录其当前互连怪兽数量到效果标签中
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_LEAVE_FIELD_P)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e3:SetLabelObject(e2)
	e3:SetOperation(c48068378.chk)
	c:RegisterEffect(e3)
end
-- 设置效果标签为当前卡片的互连怪兽数量
function c48068378.chk(e,tp,eg,ep,ev,re,r,rp)
	e:GetLabelObject():SetLabel(e:GetHandler():GetMutualLinkedGroupCount())
end
-- 连接素材过滤器：筛选等级不超过4星且种族为电子界的怪兽
function c48068378.matfilter(c)
	return c:IsLevelBelow(4) and c:IsLinkRace(RACE_CYBERSE)
end
-- 创建一个影响全场玩家的永续效果，禁止召唤等级3以上的连接怪兽
function c48068378.limop(e,tp,eg,ep,ev,re,r,rp,c)
	-- ①：这张卡特殊召唤成功的场合发动。这个回合，自己不能把连接3以上的连接怪兽连接召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTarget(c48068378.splimit)
	-- 将效果注册到游戏环境，使该效果生效
	Duel.RegisterEffect(e1,tp)
end
-- 限制条件函数：判断目标怪兽是否为等级3以上的连接怪兽且通过连接召唤方式出场
function c48068378.splimit(e,c,tp,sumtp,sumpos)
	return c:IsType(TYPE_LINK) and c:IsLinkAbove(3) and bit.band(sumtp,SUMMON_TYPE_LINK)==SUMMON_TYPE_LINK
end
-- 发动条件函数：判断标签中的互连怪兽数量大于0
function c48068378.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetLabel()>0
end
-- 设置连锁处理信息：确定将要特殊召唤的衍生物数量和位置
function c48068378.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检测玩家场上是否有至少1个空位
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		-- 检测玩家是否可以特殊召唤指定参数的衍生物
		and Duel.IsPlayerCanSpecialSummonMonster(tp,48068379,0,TYPES_TOKEN_MONSTER,0,0,1,RACE_CYBERSE,ATTRIBUTE_LIGHT) end
	-- 设置操作信息：标记本次效果将特殊召唤2只衍生物
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,2,tp,0)
	-- 设置操作信息：标记本次效果将特殊召唤2只衍生物
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,0)
end
-- ②：互相连接状态的这张卡被解放的场合才能发动。在自己场上把2只「连接衍生物」（电子界族·光·1星·攻/守0）特殊召唤。
function c48068378.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) or Duel.GetLocationCount(tp,LOCATION_MZONE)<2
		-- 检测玩家是否可以特殊召唤指定参数的衍生物
		or not Duel.IsPlayerCanSpecialSummonMonster(tp,48068379,0,TYPES_TOKEN_MONSTER,0,0,1,RACE_CYBERSE,ATTRIBUTE_LIGHT) then return end
	for i=1,2 do
		-- 创建一张编号为48068379的衍生物卡片
		local token=Duel.CreateToken(tp,48068379)
		-- 将衍生物以特殊召唤方式加入场上
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
	end
	-- 完成所有特殊召唤步骤
	Duel.SpecialSummonComplete()
end
