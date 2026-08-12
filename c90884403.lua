--究極幻神 アルティミトル・ビシバールキン
-- 效果：
-- 规则上，这张卡的等级当作12星使用。这张卡不能同调召唤，把自己场上的8星以上而相同等级的调整和调整以外的怪兽各1只送去墓地的场合才能特殊召唤。
-- ①：这张卡不会被效果破坏，攻击力上升场上的怪兽数量×1000。
-- ②：1回合1次，自己·对方的主要阶段才能发动。在双方场上把相同数量的「邪眼神衍生物」（恶魔族·暗·1星·攻/守0）尽可能守备表示特殊召唤。这个回合这张卡不能攻击。
function c90884403.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能同调召唤，把自己场上的8星以上而相同等级的调整和调整以外的怪兽各1只送去墓地的场合才能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- 把自己场上的8星以上而相同等级的调整和调整以外的怪兽各1只送去墓地的场合才能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_EXTRA)
	e2:SetCondition(c90884403.sprcon)
	e2:SetTarget(c90884403.sprtg)
	e2:SetOperation(c90884403.sprop)
	c:RegisterEffect(e2)
	-- ①：这张卡不会被效果破坏
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	-- 攻击力上升场上的怪兽数量×1000。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_UPDATE_ATTACK)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetValue(c90884403.atkval)
	c:RegisterEffect(e4)
	-- ②：1回合1次，自己·对方的主要阶段才能发动。在双方场上把相同数量的「邪眼神衍生物」（恶魔族·暗·1星·攻/守0）尽可能守备表示特殊召唤。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(90884403,0))  --"特殊召唤衍生物"
	e5:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e5:SetType(EFFECT_TYPE_QUICK_O)
	e5:SetCode(EVENT_FREE_CHAIN)
	e5:SetRange(LOCATION_MZONE)
	e5:SetHintTiming(0,TIMING_MAIN_END)
	e5:SetCountLimit(1)
	e5:SetCondition(c90884403.spcon)
	e5:SetTarget(c90884403.sptg)
	e5:SetOperation(c90884403.spop)
	c:RegisterEffect(e5)
end
-- 过滤场上表侧表示、等级8以上且能送去墓地的怪兽
function c90884403.sprfilter(c)
	return c:IsFaceup() and c:IsLevelAbove(8) and c:IsAbleToGraveAsCost()
end
-- 检查选取的怪兽组合是否为1只调整和1只非调整，且能从额外卡组特殊召唤该卡
function c90884403.fselect(g,tp,sc)
	-- 检查选取的卡片组是否恰好包含1张调整怪兽和1张非调整怪兽
	if not aux.gffcheck(g,Card.IsType,TYPE_TUNER,aux.NOT(Card.IsType),TYPE_TUNER)
		-- 检查将选取的怪兽送去墓地后，额外卡组是否有可用的怪兽区域用于特殊召唤
		or Duel.GetLocationCountFromEx(tp,tp,g,sc)<=0 then return false end
	local tc1=g:GetFirst()
	local tc2=g:GetNext()
	return tc1:IsLevel(tc2:GetLevel())
end
-- 特殊召唤规则的条件判定函数
function c90884403.sprcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取自己场上满足特殊召唤素材条件的怪兽组
	local g=Duel.GetMatchingGroup(c90884403.sprfilter,tp,LOCATION_MZONE,0,nil)
	return g:CheckSubGroup(c90884403.fselect,2,2,tp,c)
end
-- 特殊召唤规则的素材选择（目标）函数
function c90884403.sprtg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取自己场上满足特殊召唤素材条件的怪兽组
	local g=Duel.GetMatchingGroup(c90884403.sprfilter,tp,LOCATION_MZONE,0,nil)
	-- 给玩家发送“请选择要送去墓地的卡”的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	local sg=g:SelectSubGroup(tp,c90884403.fselect,true,2,2,tp,c)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 特殊召唤规则的具体执行（操作）函数
function c90884403.sprop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选作特殊召唤素材的怪兽送去墓地
	Duel.SendtoGrave(g,REASON_SPSUMMON)
	g:DeleteGroup()
end
-- 计算攻击力上升值的函数
function c90884403.atkval(e,c)
	-- 返回双方场上怪兽数量乘以1000的数值
	return Duel.GetFieldGroupCount(c:GetControler(),LOCATION_MZONE,LOCATION_MZONE)*1000
end
-- 衍生物特殊召唤效果的发动条件判定函数
function c90884403.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前的游戏阶段
	local ph=Duel.GetCurrentPhase()
	return ph==PHASE_MAIN1 or ph==PHASE_MAIN2
end
-- 衍生物特殊召唤效果的目标（判定）函数
function c90884403.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己场上主要怪兽区域的空位数
	local ft1=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 获取对方场上主要怪兽区域的空位数
	local ft2=Duel.GetLocationCount(1-tp,LOCATION_MZONE)
	local ct=math.min(ft1,ft2)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return ct>0 and not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检查自己是否能在自己场上特殊召唤「邪眼神衍生物」
		and Duel.IsPlayerCanSpecialSummonMonster(tp,90884404,0,TYPES_TOKEN_MONSTER,0,0,1,RACE_FIEND,ATTRIBUTE_DARK,POS_FACEUP_DEFENSE)
		-- 检查自己是否能在对方场上特殊召唤「邪眼神衍生物」
		and Duel.IsPlayerCanSpecialSummonMonster(tp,90884404,0,TYPES_TOKEN_MONSTER,0,0,1,RACE_FIEND,ATTRIBUTE_DARK,POS_FACEUP_DEFENSE,1-tp) end
	-- 设置连锁处理信息：包含衍生物特殊召唤，数量为双方场上空位较小值的两倍
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,ct*2,0,0)
	-- 设置连锁处理信息：包含特殊召唤，数量为双方场上空位较小值的两倍
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,ct*2,0,0)
end
-- 衍生物特殊召唤效果的具体执行（操作）函数
function c90884403.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取自己场上主要怪兽区域的空位数
	local ft1=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 获取对方场上主要怪兽区域的空位数
	local ft2=Duel.GetLocationCount(1-tp,LOCATION_MZONE)
	local ct=math.min(ft1,ft2)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if ct>0 and not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检查自己是否能在自己场上特殊召唤「邪眼神衍生物」
		and Duel.IsPlayerCanSpecialSummonMonster(tp,90884404,0,TYPES_TOKEN_MONSTER,0,0,1,RACE_FIEND,ATTRIBUTE_DARK,POS_FACEUP_DEFENSE)
		-- 检查自己是否能在对方场上特殊召唤「邪眼神衍生物」
		and Duel.IsPlayerCanSpecialSummonMonster(tp,90884404,0,TYPES_TOKEN_MONSTER,0,0,1,RACE_FIEND,ATTRIBUTE_DARK,POS_FACEUP_DEFENSE,1-tp) then
		for i=1,ct do
			-- 创建「邪眼神衍生物」的卡片数据
			local token=Duel.CreateToken(tp,90884404)
			-- 将创建的衍生物以守备表示特殊召唤到自己场上（分步处理）
			Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
			-- 再次创建「邪眼神衍生物」的卡片数据
			token=Duel.CreateToken(tp,90884404)
			-- 将创建的衍生物以守备表示特殊召唤到对方场上（分步处理）
			Duel.SpecialSummonStep(token,0,tp,1-tp,false,false,POS_FACEUP_DEFENSE)
		end
		-- 完成所有分步特殊召唤的处理
		Duel.SpecialSummonComplete()
	end
	if c:IsRelateToEffect(e) then
		-- 这个回合这张卡不能攻击。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_CANNOT_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
