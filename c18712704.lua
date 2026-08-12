--インフェルニティ・フォース
-- 效果：
-- 自己手卡是0张的场合，名字带有「永火」的怪兽被选择作为攻击对象时才能发动。把1只攻击怪兽破坏，选择自己墓地存在的1只名字带有「永火」的怪兽特殊召唤。
function c18712704.initial_effect(c)
	-- 创建效果，设置效果类别为破坏和特殊召唤，类型为发动效果，属性为取对象效果，触发事件为被选为攻击对象，条件函数为c18712704.condition，目标函数为c18712704.target，发动函数为c18712704.activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_BE_BATTLE_TARGET)
	e1:SetCondition(c18712704.condition)
	e1:SetTarget(c18712704.target)
	e1:SetOperation(c18712704.activate)
	c:RegisterEffect(e1)
end
-- 效果发动条件：自己手卡为0张且攻击怪兽正面表示存在且为永火卡组
function c18712704.condition(e,tp,eg,ep,ev,re,r,rp)
	local att=eg:GetFirst()
	-- 自己手卡为0张且攻击怪兽正面表示存在且为永火卡组
	return Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)==0 and att:IsFaceup() and att:IsSetCard(0xb)
end
-- 过滤墓地中的永火怪兽，满足特殊召唤条件
function c18712704.filter(c,e,tp)
	return c:IsSetCard(0xb) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置效果目标：攻击怪兽可破坏且墓地存在永火怪兽可特殊召唤
function c18712704.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取当前攻击怪兽
	local tg=Duel.GetAttacker()
	if chkc then return false end
	-- 检查攻击怪兽是否在场上、可被破坏、可成为效果对象且自己场上存在召唤区域
	if chk==0 then return tg:IsOnField() and tg:IsDestructable() and tg:IsCanBeEffectTarget(e) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查墓地是否存在满足条件的永火怪兽
		and Duel.IsExistingTarget(c18712704.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 将攻击怪兽设置为效果对象
	Duel.SetTargetCard(tg)
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择墓地中的永火怪兽作为特殊召唤对象
	local g=Duel.SelectTarget(tp,c18712704.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息：破坏攻击怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,tg,1,0,0)
	-- 设置操作信息：特殊召唤墓地中的永火怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果发动处理函数：获取操作信息中的破坏和特殊召唤对象，执行破坏和特殊召唤操作
function c18712704.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取操作信息中的特殊召唤对象
	local ex,sg=Duel.GetOperationInfo(0,CATEGORY_SPECIAL_SUMMON)
	-- 获取操作信息中的破坏对象
	local ex,dg=Duel.GetOperationInfo(0,CATEGORY_DESTROY)
	local sc=sg:GetFirst()
	local dc=dg:GetFirst()
	if dc:IsRelateToEffect(e) and dc:IsAttackPos() then
		-- 将破坏对象破坏
		Duel.Destroy(dg,REASON_EFFECT)
		-- 检查特殊召唤对象是否有效且场上存在召唤区域
		if sc:IsRelateToEffect(e) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and sc:IsCanBeSpecialSummoned(e,0,tp,false,false) then
			-- 将特殊召唤对象特殊召唤到场上
			Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
