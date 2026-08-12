--眠れる羊 スケープ・ゴート
-- 效果：
-- ①：在自己场上把最多4只「替罪羊衍生物」（兽族·地·1星·攻/守0）守备表示特殊召唤。对方场上有怪兽存在的场合，可以再从卡组把1只「疾风之豹战士」特殊召唤。这个回合，这衍生物不能为上级召唤而解放，自己不是融合怪兽不能从额外卡组特殊召唤。有「时间黑魔术师」的卡名记述的自己场上的卡被战斗·效果破坏的场合，可以作为代替把这个效果特殊召唤的自己场上1只衍生物破坏。
local s,id,o=GetID()
-- 初始化卡片效果：注册记载的卡名，并创建本卡的魔法卡发动效果（自由时点、含特殊召唤·衍生物·卡组特殊召唤分类）并登记到卡片上
function s.initial_effect(c)
	-- 在这张卡上登记卡名记载信息：本卡记述了「疾风之豹战士」（77482666）和「时间黑魔术师」（40235813）这两张卡名
	aux.AddCodeList(c,77482666,40235813)
	-- ①：在自己场上把最多4只「替罪羊衍生物」（兽族·地·1星·攻/守0）守备表示特殊召唤。对方场上有怪兽存在的场合，可以再从卡组把1只「疾风之豹战士」特殊召唤。这个回合，这衍生物不能为上级召唤而解放，自己不是融合怪兽不能从额外卡组特殊召唤。有「时间黑魔术师」的卡名记述的自己场上的卡被战斗·效果破坏的场合，可以作为代替把这个效果特殊召唤的自己场上1只衍生物破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"发动"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 发动条件检查：确认自己主要怪兽区有空位且可以把替罪羊衍生物特殊召唤时本卡才能发动
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上主要怪兽区是否有可用空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并确认自己可以把「替罪羊衍生物」（兽族·地·1星·攻/守0）守备表示特殊召唤到自己场上
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id+o,0,TYPES_TOKEN_MONSTER,0,0,1,RACE_BEAST,ATTRIBUTE_EARTH,POS_FACEUP_DEFENSE) end
	-- 设置操作信息：告知本连锁将产生1只衍生物
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 设置操作信息：告知本连锁将进行1次特殊召唤（具体对象在效果处理时确定）
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
-- 过滤器函数：筛选卡号为77482666（「疾风之豹战士」）且可以被特殊召唤的卡
function s.spfilter(c,e,tp)
	return c:IsCode(77482666) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果处理主流程：计算可特殊召唤的衍生物数量，特殊召唤衍生物并赋予代替破坏和不能解放的效果，对方场上有怪兽时再询问是否从卡组特殊召唤「疾风之豹战士」，最后注册本回合只能从额外卡组特殊召唤融合怪兽的限制
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己主要怪兽区的可用空格数
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft>4 then ft=4 end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 确认自己可以特殊召唤替罪羊衍生物且场上至少还有1个空位时才继续处理
	if Duel.IsPlayerCanSpecialSummonMonster(tp,id+o,0,TYPES_TOKEN_MONSTER,0,0,1,RACE_BEAST,ATTRIBUTE_EARTH,POS_FACEUP_DEFENSE) and ft>0 then
		if ft>1 then
			local ct={}
			for i=ft,1,-1 do
				table.insert(ct,i)
			end
			-- 向玩家提示选择要特殊召唤的衍生物数量
			Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,1))  --"请选择特殊召唤的数量"
			-- 让玩家宣言特殊召唤衍生物的数量（1到可用空位数之间），并以其为最终特殊召唤数量
			ft=Duel.AnnounceNumber(tp,1,table.unpack(ct))
		end
		for cid=1,ft do
			-- 生成对应卡号的替罪羊衍生物卡片
			local token=Duel.CreateToken(tp,id+o*cid)
			-- 把这只衍生物以守备表示特殊召唤到自己场上（分步特殊召唤流程）
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
			-- 这个回合，这衍生物不能为上级召唤而解放，自己不是融合怪兽不能从额外卡组特殊召唤。对方场上有怪兽存在的场合，可以再从卡组把1只「疾风之豹战士」特殊召唤。
			local e2=Effect.CreateEffect(e:GetHandler())
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_UNRELEASABLE_SUM)
			e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e2:SetValue(1)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			token:RegisterEffect(e2,true)
		end
		-- 结束分步特殊召唤流程，完成这批衍生物的特殊召唤
		Duel.SpecialSummonComplete()
		-- 立刻刷新场地信息，更新场上状态
		Duel.AdjustAll()
		-- 检查自己主要怪兽区是否仍有可用空格
		if Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			-- 并检查对方场上是否存在怪兽
			and Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_MZONE,1,nil)
			-- 并检查自己卡组里是否有可以特殊召唤的「疾风之豹战士」
			and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp)
			-- 并向玩家询问是否把「疾风之豹战士」特殊召唤
			and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否把「疾风之豹战士」特殊召唤？"
			-- 中断当前效果处理，使之后的特殊召唤视为不同时处理
			Duel.BreakEffect()
			-- 向玩家提示请选择要特殊召唤的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			-- 从自己卡组选择1只满足条件的「疾风之豹战士」
			local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
			if g:GetCount()>0 then
				-- 把选择的「疾风之豹战士」从卡组特殊召唤到自己场上
				Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
			end
		end
	end
	-- 这个回合，自己不是融合怪兽不能从额外卡组特殊召唤。有「时间黑魔术师」的卡名记述的自己场上的卡被战斗·效果破坏的场合，可以作为代替把这个效果特殊召唤的自己场上1只衍生物破坏。
	local e3=Effect.CreateEffect(e:GetHandler())
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetTargetRange(1,0)
	e3:SetTarget(s.splimit)
	e3:SetReset(RESET_PHASE+PHASE_END)
	-- 把这个额外卡组特殊召唤限制效果注册给发动玩家，持续到回合结束
	Duel.RegisterEffect(e3,tp)
end
-- 特殊召唤限制函数：对象是不在额外卡组的卡以及融合怪兽以外的额外卡组怪兽，即自己不是融合怪兽不能从额外卡组特殊召唤
function s.splimit(e,c)
	return not c:IsType(TYPE_FUSION) and c:IsLocation(LOCATION_EXTRA)
end
-- 代替破坏的过滤函数：筛选自己场上正面表示、记述有「时间黑魔术师」卡名、因战斗或效果被破坏且非代替破坏的卡
function s.rfilter(c,tp)
	-- 卡需满足：正面表示、效果文本记述着「时间黑魔术师」、因战斗·效果被破坏且这次破坏不是代替破坏
	return c:IsFaceup() and aux.IsCodeListed(c,40235813) and c:IsReason(REASON_BATTLE+REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
		and c:IsControler(tp)
end
-- 代替破坏的发动条件检查：该衍生物控制权与持有者一致、存在满足条件的被破坏卡、且衍生物自身可以被破坏且未被确定破坏
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:GetControler()==c:GetOwner() and eg:IsExists(s.rfilter,1,c,tp)
		and c:IsDestructable(e) and not c:IsStatus(STATUS_DESTROY_CONFIRMED) end
	-- 询问玩家是否适用代替破坏（破坏这只衍生物）
	if Duel.SelectEffectYesNo(tp,c,96) then
		-- 以效果破坏并作为代替破坏处理，把这只衍生物破坏
		Duel.Destroy(c,REASON_EFFECT+REASON_REPLACE)
		return true
	else return false end
end
-- 代替破坏的判定函数：确认被破坏的卡是正面表示、记述着「时间黑魔术师」卡名、不是该衍生物自身、且控制者为本效果登记的玩家
function s.repval(e,c)
	-- 返回是否满足：被破坏的卡为正面表示、记述有「时间黑魔术师」卡名、不是衍生物自身且由该玩家操控
	return c:IsFaceup() and aux.IsCodeListed(c,40235813) and c~=e:GetHandler() and c:IsControler(e:GetLabel())
end
