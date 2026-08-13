--スプリガンズ・ブラスト！
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己场上有「护宝炮妖」怪兽存在的场合，指定对方的主要怪兽区域1处才能发动（自己场上有需以「阿不思的落胤」为融合素材的融合怪兽存在的场合，这个效果指定的区域可以变成2处）。那个区域有表侧表示怪兽存在的场合，那只怪兽在这个回合不能直接攻击，效果无效化。那个区域没有怪兽存在的场合，这个回合，指定的区域不能使用。
function c10584050.initial_effect(c)
	-- 将「阿不思的落胤」(68468459)作为本卡效果文中提到的卡名登记到卡片c上，使相关判断能识别本卡的效果文含有该卡名。
	aux.AddCodeList(c,68468459)
	-- 这个卡名的卡在1回合只能发动1张。①：自己场上有「护宝炮妖」怪兽存在的场合，指定对方的主要怪兽区域1处才能发动（自己场上有需以「阿不思的落胤」为融合素材的融合怪兽存在的场合，这个效果指定的区域可以变成2处）。那个区域有表侧表示怪兽存在的场合，那只怪兽在这个回合不能直接攻击，效果无效化。那个区域没有怪兽存在的场合，这个回合，指定的区域不能使用。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e1:SetCountLimit(1,10584050+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c10584050.condition)
	e1:SetTarget(c10584050.target)
	e1:SetOperation(c10584050.activate)
	c:RegisterEffect(e1)
end
-- 定义筛选函数：用于筛选出场上的表侧表示且卡名属于「护宝炮妖」系列的怪兽。
function c10584050.confilter(c)
	return c:IsFaceup() and c:IsSetCard(0x155)
end
-- 定义发动条件：自己场上存在至少1只满足confilter的「护宝炮妖」怪兽才能发动。
function c10584050.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在表侧表示的「护宝炮妖」怪兽。
	return Duel.IsExistingMatchingCard(c10584050.confilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 定义追加条件筛选：判断自己场上是否存在表侧表示的融合怪兽，且其融合素材包含「阿不思的落胤」。
function c10584050.cfilter(c)
	-- 判断该怪兽是否为表侧表示、融合怪兽，并且其素材记载中包含「阿不思的落胤」。
	return c:IsFaceup() and c:IsType(TYPE_FUSION) and aux.IsMaterialListCode(c,68468459)
end
-- 定义区域判定函数：用于检查对方主要怪兽区中指定编号的格子里是否有里侧表示怪兽。
function c10584050.fdfilter(c,i)
	return c:IsFacedown() and c:GetSequence()==i
end
-- 效果发动时的目标选择：先统计对方主要怪兽区中被里侧怪兽占据的格子，再让玩家选择1处可指定的区域；若满足追加条件且还有空位，则询问是否选择第2处区域并合并选择结果。
function c10584050.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local fdzone=0
	for i=0,4 do
		-- 遍历对方主要怪兽区0~4号区域，若某个区域存在里侧表示怪兽，则将该区域计入fdzone，后续不可选择该区域。
		if Duel.IsExistingMatchingCard(c10584050.fdfilter,tp,0,LOCATION_MZONE,1,nil,i) then
			fdzone=fdzone|1<<i
		end
	end
	if chk==0 then return ~fdzone&0x1f>0 end
	-- 从对方主要怪兽区中可指定的区域里选择1处，选择范围排除有里侧怪兽的区域；选择结果用区域掩码dis表示。
	local dis=Duel.SelectField(tp,1,0,LOCATION_MZONE,(fdzone|0x60)<<16)
	-- 检查自己场上是否有素材包含「阿不思的落胤」的表侧融合怪兽，并且排除已选区域后仍存在可追加选择的有效区域。
	if Duel.IsExistingMatchingCard(c10584050.cfilter,tp,LOCATION_MZONE,0,1,nil) and ~(fdzone|(dis>>16))&0x1f>0
		-- 如果满足追加条件，则弹出确认框，让玩家选择是否再指定1处区域。
		and Duel.SelectYesNo(tp,aux.Stringid(10584050,0)) then  --"是否再选择1个区域？"
		-- 玩家选择追加后，再选择1处区域，并与之前的dis按位或合并，形成最终指定的区域集合。
		dis=dis|Duel.SelectField(tp,1,0,LOCATION_MZONE,(fdzone|(dis>>16)|0x60)<<16)
	end
	e:SetLabel(dis)
	-- 向双方展示并提示最终指定的区域，用于动画和连锁确认。
	Duel.Hint(HINT_ZONE,tp,dis)
end
-- 定义筛选函数：取得在指定区域（dis）中表侧表示存在的怪兽。
function c10584050.disfilter2(c,dis)
	return c:IsFaceup() and (2^c:GetSequence())*0x10000&dis~=0
end
-- 定义筛选函数：取得在指定区域（dis）中里侧表示存在的怪兽，用于从后续封禁区域中排除。
function c10584050.disfilter3(c,dis)
	return c:IsFacedown() and (2^c:GetSequence())*0x10000&dis~=0
end
-- 效果处理：对指定区域中的表侧表示怪兽施加本回合不能直接攻击、效果无效化的状态；对剩余没有表侧怪兽（且非里侧怪兽占据）的空区域，施加本回合不能使用的封禁。
function c10584050.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local dis=e:GetLabel()
	-- 获取所有被指定的区域中存在的表侧表示怪兽，准备逐个附加无效化效果。
	local g=Duel.GetMatchingGroup(c10584050.disfilter2,tp,0,LOCATION_MZONE,nil,dis)
	local tc=g:GetFirst()
	while tc do
		-- 那只怪兽在这个回合不能直接攻击
		local e0=Effect.CreateEffect(c)
		e0:SetType(EFFECT_TYPE_SINGLE)
		e0:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
		e0:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e0)
		-- 将该怪兽已经发动的相关连锁效果全部无效化，使它的效果无效化能覆盖正在处理或已适用的效果。
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 效果无效化
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 效果无效化
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
		dis=dis-(2^tc:GetSequence())*0x10000
		tc=g:GetNext()
	end
	-- 获取指定区域中存在的里侧表示怪兽，用于将这些区域从“不能使用的区域”掩码中移除。因里侧怪兽区域不能被指定，故不封禁该区域。
	local sg=Duel.GetMatchingGroup(c10584050.disfilter3,tp,0,LOCATION_MZONE,nil,dis)
	local sc=sg:GetFirst()
	while sc do
		dis=dis-(2^sc:GetSequence())*0x10000
		sc=sg:GetNext()
	end
	if dis~=0 then
		if tp==1 then
			dis=((dis&0xffff)<<16)|((dis>>16)&0xffff)
		end
		-- 那个区域没有怪兽存在的场合，这个回合，指定的区域不能使用。
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_FIELD)
		e3:SetCode(EFFECT_DISABLE_FIELD)
		e3:SetValue(dis)
		e3:SetReset(RESET_PHASE+PHASE_END)
		-- 将区域封禁效果注册到场上，持续到回合结束，实现“指定的区域不能使用”。
		Duel.RegisterEffect(e3,tp)
	end
end
