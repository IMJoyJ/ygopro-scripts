--眠れる羊 スケープ・ゴート
-- 效果：
-- ①：在自己场上把最多4只「替罪羊衍生物」（兽族·地·1星·攻/守0）守备表示特殊召唤。对方场上有怪兽存在的场合，可以再从卡组把1只「疾风之豹战士」特殊召唤。这个回合，这衍生物不能为上级召唤而解放，自己不是融合怪兽不能从额外卡组特殊召唤。有「时间黑魔术师」的卡名记述的自己场上的卡被战斗·效果破坏的场合，可以作为代替把这个效果特殊召唤的自己场上1只衍生物破坏。
local s,id,o=GetID()
-- 初始化卡片效果：登记卡名记载列表，并注册特殊召唤最多4只「替罪羊衍生物」及后续「疾风之豹战士」特召与自肃的魔法卡发动效果
function s.initial_effect(c)
	-- 记录此卡效果文本中记述有「疾风之豹战士」和「时间黑魔术师」的卡名
	aux.AddCodeList(c,77482666,40235813)
	-- ①：在自己场上把最多4只「替罪羊衍生物」（兽族·地·1星·攻/守0）守备表示特殊召唤。对方场上有怪兽存在的场合，可以再从卡组把1只「疾风之豹战士」特殊召唤。这个回合，这衍生物不能为上级召唤而解放，自己不是融合怪兽不能从额外卡组特殊召唤。有「时间黑魔术师」的卡名记述的自己场上的卡被战斗·效果破坏的场合，可以作为代替把这个效果特殊召唤的自己场上1只衍生物破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"发动"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN+CATEGORY_DECKDES+CATEGORY_DECK_SPSUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 发动前确认己方怪兽区有空位且可以表侧守备表示特殊召唤「替罪羊衍生物」，并登记衍生物与特殊召唤操作信息
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查己方怪兽区是否至少有1个可用空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查己方是否可以表侧守备表示特殊召唤兽族·地属性·1星·攻守0的「替罪羊衍生物」
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id+o,0,TYPES_TOKEN_MONSTER,0,0,1,RACE_BEAST,ATTRIBUTE_EARTH,POS_FACEUP_DEFENSE) end
	-- 登记生成衍生物的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 登记特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
-- 过滤卡组中卡名为「疾风之豹战士」且可特殊召唤的怪兽
function s.spfilter(c,e,tp)
	return c:IsCode(77482666) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果处理：计算可生成数量并让玩家宣言数量，分步特召「替罪羊衍生物」并赋予其代破与禁止上级解放效果，完成后若满足条件可从卡组特召「疾风之豹战士」
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取己方怪兽区当前的可用空位数
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft>4 then ft=4 end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 确认当前仍能特殊召唤「替罪羊衍生物」且怪兽区可用数量大于0
	if Duel.IsPlayerCanSpecialSummonMonster(tp,id+o,0,TYPES_TOKEN_MONSTER,0,0,1,RACE_BEAST,ATTRIBUTE_EARTH,POS_FACEUP_DEFENSE) and ft>0 then
		if ft>1 then
			local ct={}
			for i=ft,1,-1 do
				table.insert(ct,i)
			end
			-- 向己方发送选择要特殊召唤的衍生物数量的提示
			Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,1))  --"请选择特殊召唤的数量"
			-- 让己方玩家从可选数量（1至当前最大可用数量ft）中宣言要特殊召唤的衍生物数量
			ft=Duel.AnnounceNumber(tp,1,table.unpack(ct))
		end
		for cid=1,ft do
			-- 为己方生成1张对应编号的「替罪羊衍生物」卡片对象
			local token=Duel.CreateToken(tp,id+o*cid)
			-- 分步将该「替罪羊衍生物」以表侧守备表示特殊召唤到己方场上
			Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
			-- 有「时间黑魔术师」的卡名记述的自己场上的卡被战斗·效果破坏的场合，可以作为代替把这个效果特殊召唤的自己场上1只衍生物破坏。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
			e1:SetCode(EFFECT_DESTROY_REPLACE)
			e1:SetRange(LOCATION_MZONE)
			e1:SetTarget(s.destg)
			e1:SetLabel(tp)
			e1:SetValue(s.repval)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			token:RegisterEffect(e1,true)
			-- 这个回合，这衍生物不能为上级召唤而解放，对方场上有怪兽存在的场合，可以再从卡组把1只「疾风之豹战士」特殊召唤。
			local e2=Effect.CreateEffect(e:GetHandler())
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_UNRELEASABLE_SUM)
			e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e2:SetValue(1)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			token:RegisterEffect(e2,true)
		end
		-- 完成分步特殊召唤流程，统一结算所有生成的衍生物的特殊召唤成功时点
		Duel.SpecialSummonComplete()
		-- 立刻刷新场地状态，使后续对方场上及己方空位检查基于最新盘面
		Duel.AdjustAll()
		-- 检查衍生物特召后己方怪兽区是否仍有空位
		if Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			-- 检查对方怪兽区是否存在至少1只怪兽
			and Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_MZONE,1,nil)
			-- 检查己方卡组是否存在可特殊召唤的「疾风之豹战士」
			and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp)
			-- 询问己方玩家是否从卡组特殊召唤1只「疾风之豹战士」
			and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否把「疾风之豹战士」特殊召唤？"
			-- 插入效果处理间断，使衍生物特召与后续卡组特召「疾风之豹战士」视为不同时处理
			Duel.BreakEffect()
			-- 向己方发送选择要特殊召唤的卡的提示
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			-- 让己方从卡组选择1只「疾风之豹战士」
			local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
			if g:GetCount()>0 then
				-- 将选中的「疾风之豹战士」以表侧表示特殊召唤到己方场上
				Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
			end
		end
	end
	-- 自己不是融合怪兽不能从额外卡组特殊召唤。有「时间黑魔术师」的卡名记述的自己场上的卡被战斗·效果破坏的场合，可以作为代替把这个效果特殊召唤的自己场上1只衍生物破坏。
	local e3=Effect.CreateEffect(e:GetHandler())
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetTargetRange(1,0)
	e3:SetTarget(s.splimit)
	e3:SetReset(RESET_PHASE+PHASE_END)
	-- 为己方玩家注册持续至回合结束的额外卡组特殊召唤自肃效果
	Duel.RegisterEffect(e3,tp)
end
-- 限制条件函数：阻止从额外卡组特殊召唤融合怪兽以外的怪兽
function s.splimit(e,c)
	return not c:IsType(TYPE_FUSION) and c:IsLocation(LOCATION_EXTRA)
end
-- 代破过滤函数：筛选己方控制的、表侧表示且记载有「时间黑魔术师」卡名、将因战斗或非代破效果被破坏的卡
function s.rfilter(c,tp)
	-- 判断卡片是否表侧表示、效果文本记载有「时间黑魔术师」且因战斗或非代破效果即将被破坏
	return c:IsFaceup() and aux.IsCodeListed(c,40235813) and c:IsReason(REASON_BATTLE+REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
		and c:IsControler(tp)
end
-- 代破效果处理：确认衍生物由原持有者控制且场上有符合代破条件的卡，若玩家同意则破坏此衍生物作为代替
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:GetControler()==c:GetOwner() and eg:IsExists(s.rfilter,1,c,tp)
		and c:IsDestructable(e) and not c:IsStatus(STATUS_DESTROY_CONFIRMED) end
	-- 询问己方玩家是否发动此衍生物的代替破坏效果
	if Duel.SelectEffectYesNo(tp,c,96) then
		-- 将作为代替的此衍生物以代替破坏的效果破坏
		Duel.Destroy(c,REASON_EFFECT+REASON_REPLACE)
		return true
	else return false end
end
-- 代破适用范围校验函数：限定仅对己方场上除自身外、表侧且记载有「时间黑魔术师」的卡生效
function s.repval(e,c)
	-- 检查待破坏的卡c是否为己方场上（由e:GetLabel()记录的原控制者）表侧表示、记载有「时间黑魔术师」且非此衍生物自身的卡
	return c:IsFaceup() and aux.IsCodeListed(c,40235813) and c~=e:GetHandler() and c:IsControler(e:GetLabel())
end
