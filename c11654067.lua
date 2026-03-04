--ファイヤー・エジェクション
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从卡组把1只炎族怪兽送去墓地。这个效果把「火山」怪兽送去墓地的场合，可以再从以下效果选1个适用。
-- ●给与对方那个等级×100伤害。
-- ●在对方场上把1只「炸弹衍生物」（炎族·炎·1星·攻/守1000）特殊召唤。这衍生物被破坏时那个控制者受到500伤害。
function c11654067.initial_effect(c)
	-- 创建效果，设置效果分类为送去墓地、伤害、从卡组处理、特殊召唤、衍生物，设置为发动效果，自由连锁，发动次数限制为1次，设置目标函数和发动函数
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_DAMAGE+CATEGORY_DECKDES+CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,11654067+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c11654067.target)
	e1:SetOperation(c11654067.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于筛选炎族且可送去墓地的怪兽
function c11654067.tgfilter(c)
	return c:IsRace(RACE_PYRO) and c:IsAbleToGrave()
end
-- 目标函数，检查是否可以发动效果
function c11654067.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足发动条件，检查卡组是否存在炎族怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c11654067.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息，指定将要从卡组送去墓地的卡
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 发动函数，处理效果的发动
function c11654067.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	-- 从卡组选择一只炎族怪兽送去墓地
	local g=Duel.SelectMatchingCard(tp,c11654067.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	-- 判断所选怪兽是否成功送去墓地且为火山族
	if tc and Duel.SendtoGrave(tc,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_GRAVE) and tc:IsSetCard(0x32) then
		local b1=tc:GetLevel()>0
		-- 判断对方场上是否有空位
		local b2=Duel.GetLocationCount(1-tp,LOCATION_MZONE,tp)>0
			-- 判断是否可以特殊召唤衍生物
			and Duel.IsPlayerCanSpecialSummonMonster(tp,11654068,0,TYPES_TOKEN_MONSTER,1000,1000,1,RACE_PYRO,ATTRIBUTE_FIRE,POS_FACEUP,1-tp)
		-- 让玩家选择效果选项
		local sel=aux.SelectFromOptions(tp,
			{b1,aux.Stringid(11654067,0)},  --"给与对方伤害"
			{b2,aux.Stringid(11654067,1)},  --"特殊召唤衍生物"
			{true,aux.Stringid(11654067,2)})  --"什么都不做"
		if sel==1 then
			-- 中断当前效果处理
			Duel.BreakEffect()
			local val=tc:GetLevel()*100
			-- 给与对方等级×100的伤害
			Duel.Damage(1-tp,val,REASON_EFFECT)
		elseif sel==2 then
			-- 中断当前效果处理
			Duel.BreakEffect()
			-- 创造一张炸弹衍生物
			local token=Duel.CreateToken(tp,11654068)
			-- 特殊召唤衍生物到对方场上
			if Duel.SpecialSummonStep(token,0,tp,1-tp,false,false,POS_FACEUP) then
				-- 为衍生物注册离开场上的效果，当其被破坏时给控制者造成500伤害
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
				e1:SetCode(EVENT_LEAVE_FIELD)
				e1:SetOperation(c11654067.damop)
				token:RegisterEffect(e1,true)
			end
			-- 完成特殊召唤步骤
			Duel.SpecialSummonComplete()
		end
	end
end
-- 衍生物被破坏时的处理函数
function c11654067.damop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsReason(REASON_DESTROY) then
		-- 给衍生物的控制者造成500伤害
		Duel.Damage(c:GetPreviousControler(),500,REASON_EFFECT)
	end
	e:Reset()
end
