--氷水帝エジル・ラーン
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：从手卡把其他的1张「冰水」卡或者1只水属性怪兽丢弃才能发动。这张卡从手卡特殊召唤。那之后，可以在自己场上把1只「冰水衍生物」（水族·水·3星·攻/守0）特殊召唤。只要这个效果特殊召唤的衍生物存在，自己不是水属性怪兽不能从额外卡组特殊召唤。
-- ②：这张卡只要有装备卡装备，卡名当作「冰水底 铬离子少女摇篮」使用。
function c18494511.initial_effect(c)
	-- 记录本卡效果文本中记载了卡名「冰水底 铬离子少女摇篮」（7142724），用于卡名相关处理。
	aux.AddCodeList(c,7142724)
	-- 这个卡名的①的效果1回合只能使用1次。①：从手卡把其他的1张「冰水」卡或者1只水属性怪兽丢弃才能发动。这张卡从手卡特殊召唤。那之后，可以在自己场上把1只「冰水衍生物」（水族·水·3星·攻/守0）特殊召唤。只要这个效果特殊召唤的衍生物存在，自己不是水属性怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(18494511,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,18494511)
	e1:SetCost(c18494511.spcost)
	e1:SetTarget(c18494511.sptg)
	e1:SetOperation(c18494511.spop)
	c:RegisterEffect(e1)
	-- 为本卡注册卡名变更效果：在怪兽区且满足codecon条件（装备着装备卡）时，卡名当作「冰水底 铬离子少女摇篮」（7142724）使用。
	aux.EnableChangeCode(c,7142724,LOCATION_MZONE,c18494511.codecon)
end
-- 定义代价筛选函数：满足「冰水」系列或水属性怪兽之一，且能够作为代价丢弃的手卡。调用处会排除本卡自身。
function c18494511.costfilter(c)
	local b1=c:IsSetCard(0x16c)
	local b2=c:IsAttribute(ATTRIBUTE_WATER) and c:IsType(TYPE_MONSTER)
	return (b1 or b2) and c:IsDiscardable()
end
-- 代价处理函数：效果发动前检查手牌中是否存在至少1张其他符合条件的卡（costfilter）；执行时选择并丢弃1张这样的手卡作为代价。
function c18494511.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查阶段（chk==0）：确认还存在至少1张除自身外的可丢弃的「冰水」卡或水属性怪兽手卡，否则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c18494511.costfilter,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 执行丢弃代价：从手牌选择1张满足costfilter且不是本卡的卡，以代价和丢弃的原因送去墓地。
	Duel.DiscardHand(tp,c18494511.costfilter,1,1,REASON_COST+REASON_DISCARD,e:GetHandler())
end
-- 目标/发动条件函数：确认自己主要怪兽区有空格，且这张卡能够用当前效果特殊召唤。
function c18494511.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件的一部分：自己场上主要怪兽区存在可用的空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：声明本次效果将特殊召唤这张卡，数量为1，供连锁判定和时点检测使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理：若这张卡仍与效果关联则将其特殊召唤；成功后若有空位且玩家可选择特殊召唤衍生物，则询问是否特殊召唤「冰水衍生物」，并在选择是时创建并特殊召唤该衍生物，同时给衍生物附加自肃效果；最后完成特殊召唤流程。
function c18494511.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判定本卡仍与当前效果关联（未被无效或离场），并将其以表侧攻击表示特殊召唤；只有特殊召唤成功才继续后续处理。
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 获取当前玩家主要怪兽区剩余可用空格数量，用于判断能否再特殊召唤衍生物。
		local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
		-- 判断场上仍有空格，且当前玩家能够按照指定数据（衍生物：18494512，水族·水·3星·攻/守0）特殊召唤衍生物。
		if ft>0 and Duel.IsPlayerCanSpecialSummonMonster(tp,18494512,0x16c,TYPES_TOKEN_MONSTER,0,0,3,RACE_AQUA,ATTRIBUTE_WATER)
			-- 弹窗询问当前玩家“是否特殊召唤衍生物？”，只有在选择“是”时才继续特招衍生物。
			and Duel.SelectYesNo(tp,aux.Stringid(18494511,1)) then  --"是否特殊召唤衍生物？"
			-- 中断当前效果处理，使后续衍生物的特殊召唤在时点上独立，避免因效果处理中造成的时点错失。
			Duel.BreakEffect()
			-- 在场上生成「冰水衍生物」（18494512）的衍生物卡，归当前玩家所有。
			local token=Duel.CreateToken(tp,18494512)
			-- 将衍生物作为特殊召唤过程的步骤，以表侧攻击表示特殊召唤到当前玩家的怪兽区。
			Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
			-- 只要这个效果特殊召唤的衍生物存在，自己不是水属性怪兽不能从额外卡组特殊召唤。②：这张卡只要有装备卡装备，卡名当作「冰水底 铬离子少女摇篮」使用。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
			e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
			e1:SetRange(LOCATION_MZONE)
			e1:SetAbsoluteRange(tp,1,0)
			e1:SetTarget(c18494511.splimit)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			token:RegisterEffect(e1,true)
			-- 完成整组特殊召唤的连锁处理，令之前的所有SpecialSummonStep召唤正式生效。
			Duel.SpecialSummonComplete()
		end
	end
end
-- 自肃限制函数的判定条件：只要该衍生物存在，额外卡组中水属性以外的怪兽不能进行特殊召唤。
function c18494511.splimit(e,c)
	return not c:IsAttribute(ATTRIBUTE_WATER) and c:IsLocation(LOCATION_EXTRA)
end
-- 卡名变更条件：这张卡装备着装备卡时，卡名当作「冰水底 铬离子少女摇篮」使用。
function c18494511.codecon(e)
	return e:GetHandler():GetEquipCount()>0
end
