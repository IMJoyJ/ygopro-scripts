--栄誉の贄
-- 效果：
-- 自己基本分是3000以下的场合，对方宣言直接攻击时才能发动。那只怪兽的攻击无效，在自己场上把2只「祭品石碑衍生物」（岩石族·地·1星·攻/守0）特殊召唤，从自己卡组把1张名字带有「地缚神」的卡加入手卡。「祭品石碑衍生物」不能为名字带有「地缚神」的怪兽的上级召唤以外而解放，也不能作为同调素材。
function c82340056.initial_effect(c)
	-- 自己基本分是3000以下的场合，对方宣言直接攻击时才能发动。那只怪兽的攻击无效，在自己场上把2只「祭品石碑衍生物」（岩石族·地·1星·攻/守0）特殊召唤，从自己卡组把1张名字带有「地缚神」的卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(c82340056.condition)
	e1:SetTarget(c82340056.target)
	e1:SetOperation(c82340056.activate)
	c:RegisterEffect(e1)
end
-- 定义发动条件函数，检查玩家LP、回合玩家以及是否为直接攻击
function c82340056.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判定自己基本分在3000以下、当前为对方回合且对方怪兽进行直接攻击
	return Duel.GetLP(tp)<=3000 and Duel.GetTurnPlayer()~=tp and Duel.GetAttackTarget()==nil
end
-- 过滤卡组中名字带有「地缚神」且可以加入手牌的卡片
function c82340056.filter(c)
	return c:IsSetCard(0x1021) and c:IsAbleToHand()
end
-- 定义效果发动目标函数，进行发动时的可行性检测
function c82340056.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检查自己场上的主要怪兽区域是否有2个以上的空位
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		-- 检查玩家是否可以特殊召唤指定的「祭品石碑衍生物」
		and Duel.IsPlayerCanSpecialSummonMonster(tp,82340057,0,TYPES_TOKEN_MONSTER,0,0,1,RACE_ROCK,ATTRIBUTE_EARTH)
		-- 检查卡组中是否存在至少1张名字带有「地缚神」的卡片
		and Duel.IsExistingMatchingCard(c82340056.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置在连锁处理中会产生2只衍生物的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,2,0,0)
	-- 设置在连锁处理中会特殊召唤2只怪兽的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,0,0)
end
-- 定义效果处理函数，执行无效攻击、检索卡片及特殊召唤衍生物的操作
function c82340056.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 无效那只怪兽的攻击，若无效失败则效果处理中止
	if not Duel.NegateAttack() then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 检查自己场上的主要怪兽区域空位是否小于2个
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<2
		-- 或者无法特殊召唤「祭品石碑衍生物」时，则效果处理中止
		or not Duel.IsPlayerCanSpecialSummonMonster(tp,82340057,0,TYPES_TOKEN_MONSTER,0,0,1,RACE_ROCK,ATTRIBUTE_EARTH) then return end
	-- 向玩家发送选择卡片加入手牌的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择1张名字带有「地缚神」的卡片
	local g=Duel.SelectMatchingCard(tp,c82340056.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()==0 then return end
	-- 将选择的卡片加入手牌
	Duel.SendtoHand(g,nil,REASON_EFFECT)
	-- 给对方确认加入手牌的卡片
	Duel.ConfirmCards(1-tp,g)
	-- 洗切玩家的手牌
	Duel.ShuffleHand(tp)
	for i=1,2 do
		-- 创建「祭品石碑衍生物」的卡片实例
		local token=Duel.CreateToken(tp,82340057)
		-- 将衍生物以表侧表示逐步特殊召唤到场上
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
		-- 「祭品石碑衍生物」不能为名字带有「地缚神」的怪兽的上级召唤以外而解放
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UNRELEASABLE_NONSUM)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(1)
		token:RegisterEffect(e1,true)
		-- 「祭品石碑衍生物」不能为名字带有「地缚神」的怪兽的上级召唤以外而解放
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_UNRELEASABLE_SUM)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		e2:SetValue(c82340056.sumlimit)
		token:RegisterEffect(e2,true)
		-- 也不能作为同调素材。
		local e3=Effect.CreateEffect(e:GetHandler())
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		e3:SetValue(1)
		token:RegisterEffect(e3,true)
	end
	-- 完成所有怪兽的特殊召唤处理
	Duel.SpecialSummonComplete()
end
-- 限制解放的怪兽必须是名字带有「地缚神」的怪兽
function c82340056.sumlimit(e,c)
	return not c:IsSetCard(0x1021)
end
