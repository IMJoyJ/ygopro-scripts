--死霊の残像
-- 效果：
-- 5星以上的恶魔族·不死族怪兽才能装备。这个卡名的①的效果1回合只能使用1次。
-- ①：可以从以下效果选择1个发动。
-- ●自己的手卡·场上的怪兽作为融合素材，把1只融合怪兽融合召唤。
-- ●把持有和装备怪兽相同种族·属性·攻击力的1只「多普勒衍生物」（5星·攻?/守0）在自己场上特殊召唤。
-- ②：装备怪兽和对方怪兽进行战斗的攻击宣言时才能发动。那只对方怪兽的攻击力下降装备怪兽的攻击力数值。
local s,id,o=GetID()
-- 初始化函数，注册卡片的所有效果，包括装备卡发动、装备限制、融合召唤、特招衍生物以及战斗时降低对方怪兽攻击力的效果
function s.initial_effect(c)
	-- 5星以上的恶魔族·不死族怪兽才能装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	-- 5星以上的恶魔族·不死族怪兽才能装备。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EQUIP_LIMIT)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetValue(s.eqlimit)
	c:RegisterEffect(e2)
	-- ●自己的手卡·场上的怪兽作为融合素材，把1只融合怪兽融合召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))  --"融合召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,id)
	e3:SetCondition(s.fcon)
	e3:SetTarget(s.ftg)
	e3:SetOperation(s.fop)
	c:RegisterEffect(e3)
	-- ●把持有和装备怪兽相同种族·属性·攻击力的1只「多普勒衍生物」（5星·攻?/守0）在自己场上特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))  --"特殊召唤衍生物"
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCountLimit(1,id)
	e4:SetCondition(s.fcon)
	e4:SetTarget(s.tokentg)
	e4:SetOperation(s.tokenop)
	c:RegisterEffect(e4)
	-- ②：装备怪兽和对方怪兽进行战斗的攻击宣言时才能发动。那只对方怪兽的攻击力下降装备怪兽的攻击力数值。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e5:SetCategory(CATEGORY_ATKCHANGE)
	e5:SetCode(EVENT_ATTACK_ANNOUNCE)
	e5:SetRange(LOCATION_SZONE)
	e5:SetCondition(s.atkcon)
	e5:SetTarget(s.atktg)
	e5:SetOperation(s.atkop)
	c:RegisterEffect(e5)
end
s.fusion_effect=true
-- 定义装备限制：只能装备给5星以上的恶魔族·不死族怪兽
function s.eqlimit(e,c)
	return c:IsLevelAbove(5) and c:IsRace(RACE_FIEND+RACE_ZOMBIE)
end
-- 过滤场上表侧表示的5星以上恶魔族·不死族怪兽
function s.filter(c)
	return c:IsFaceup() and c:IsLevelAbove(5) and c:IsRace(RACE_FIEND+RACE_ZOMBIE)
end
-- 装备卡发动时的效果目标选择与处理
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.filter(chkc) end
	-- 判定场上是否存在可装备的合法怪兽
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要装备的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择1只符合条件的怪兽作为装备对象
	Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理信息为装备此卡
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 装备卡发动成功后的具体装备处理
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取发动时选择的装备目标怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将此卡作为装备卡装备给目标怪兽
		Duel.Equip(tp,c,tc)
	end
end
-- 效果发动条件：此卡必须有装备怪兽
function s.fcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetEquipTarget()
end
-- 过滤不受当前效果影响的怪兽
function s.filter1(c,e)
	return not c:IsImmuneToEffect(e)
end
-- 过滤额外卡组中可以使用当前素材进行融合召唤的融合怪兽
function s.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 融合召唤效果的发动准备与合法性判定
function s.ftg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 获取玩家手卡和场上可用的融合素材
		local mg1=Duel.GetFusionMaterial(tp)
		-- 判定额外卡组是否存在可以使用手卡·场上素材进行融合召唤的怪兽
		local res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			-- 检查是否存在可适用的替代融合效果
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 判定在使用替代融合素材时，额外卡组是否存在可融合召唤的怪兽
				res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
			end
		end
		return res
	end
	-- 向对方玩家提示当前发动的效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置效果处理信息为从额外卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 融合召唤效果的具体处理逻辑
function s.fop(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 获取并过滤出不受当前效果影响的可用融合素材
	local mg1=Duel.GetFusionMaterial(tp):Filter(s.filter1,nil,e)
	-- 获取额外卡组中所有可融合召唤的怪兽组合
	local sg1=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg2=nil
	local sg2=nil
	-- 再次检查并获取替代融合效果
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 获取使用替代融合素材时可融合召唤的怪兽组合
		sg2=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 提示玩家选择要特殊召唤的融合怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判定是否使用常规融合素材进行召唤，或者玩家选择不使用替代融合效果
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not (ce~=nil and Duel.SelectYesNo(tp,ce:GetDescription()))) then
			-- 玩家选择用于融合召唤该怪兽的常规融合素材
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			tc:SetMaterial(mat1)
			-- 将选定的融合素材送去墓地
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果处理，使后续的特殊召唤不与送墓同时处理
			Duel.BreakEffect()
			-- 将融合怪兽以融合召唤的方式表侧表示特殊召唤到场上
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		elseif ce~=nil then
			-- 玩家选择用于替代融合效果的融合素材
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end
-- 特殊召唤衍生物效果的发动准备与合法性判定
function s.tokentg(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=e:GetHandler():GetEquipTarget()
	-- 判定自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判定玩家是否能特殊召唤具有装备怪兽相同攻击力、种族、属性的5星衍生物
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id+o,0,TYPES_TOKEN_MONSTER,tc:GetAttack(),0,5,tc:GetRace(),tc:GetAttribute()) end
	-- 向对方玩家提示当前发动的效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置效果处理信息为生成衍生物
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 设置效果处理信息为特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
-- 特殊召唤衍生物效果的具体处理逻辑
function s.tokenop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=c:GetEquipTarget()
	-- 再次判定自己场上是否有可用的怪兽区域
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 再次判定是否能特殊召唤符合条件的衍生物
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id+o,0,TYPES_TOKEN_MONSTER,tc:GetAttack(),0,5,tc:GetRace(),tc:GetAttribute()) then
		-- 在后台创建「多普勒衍生物」卡片
		local token=Duel.CreateToken(tp,id+o)
		-- ●把持有和装备怪兽相同种族·属性·攻击力的1只「多普勒衍生物」（5星·攻?/守0）在自己场上特殊召唤。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK)
		e1:SetValue(tc:GetAttack())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD)
		token:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_CHANGE_RACE)
		e2:SetValue(tc:GetRace())
		token:RegisterEffect(e2)
		local e3=e1:Clone()
		e3:SetCode(EFFECT_CHANGE_ATTRIBUTE)
		e3:SetValue(tc:GetAttribute())
		token:RegisterEffect(e3)
		-- 将创建的衍生物表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 攻击力下降效果的发动条件判定：装备怪兽与对方怪兽进行战斗的攻击宣言时，且装备怪兽攻击力不为0
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetHandler():GetEquipTarget()
	local tc=ec:GetBattleTarget()
	e:SetLabelObject(tc)
	return not ec:IsAttack(0) and tc and tc:IsFaceup()
end
-- 攻击力下降效果的发动准备，建立与战斗对方怪兽的关系
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	e:GetLabelObject():CreateEffectRelation(e)
end
-- 攻击力下降效果的具体处理逻辑
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ec=c:GetEquipTarget()
	local tc=e:GetLabelObject()
	if ec:GetAttack() > 0 and tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsControler(1-tp) and not tc:IsImmuneToEffect(e) then
		-- 那只对方怪兽的攻击力下降装备怪兽的攻击力数值。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue((ec:GetAttack())*-1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
